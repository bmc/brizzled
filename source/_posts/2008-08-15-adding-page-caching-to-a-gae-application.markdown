---
layout: post
comments: true
title: "Adding Page caching to a GAE application"
date: 2008-08-15 00:00
categories: [python, App Engine, blogging, programming]
toc: true
---

# Introduction

In a [previous article][], I discussed blogging software that runs on
Google's [App Engine][]. I use similar software to run this blog; in this
article, I discuss one scheme for adding page caching to the software.

<!-- more -->

# The Problem: Using Too Much CPU

If you read my [previous article][], you may recall that I chose to use
[reStructuredText][] (RST) as my markup language. I also stated:

> Converting the markup when we save the article is more efficient, but it
> means we have to store the generated HTML and reconvert all previously
> saved articles whenever we change the templates or the style sheet. It's
> simpler to convert on the fly. If this strategy ends up causing a
> performance problem, we can always go back later and add page caching.

Well, this strategy *does* end up causing a performance problem. On
every page view, GAE was dumping this message to my application's
log:

    This request used a high amount of CPU, and was roughly 6.6 times over
    the average request CPU limit. High CPU requests have a small quota,
    and if you exceed this quota, your app will be temporarily disabled.

The number varies and is sometimes twice as high as 6.6.

# The Solution: A Page Cache

I [profiled][] my blog application and confirmed my assumption that the CPU
usage was primarily caused by the conversion of RST to HTML. I decided to
address this problem with a cache, on the theory that the RST-to-HTML
markup was causing the CPU spike, rather than the database lookup.

GAE provides a [memory cache API][] that (as the GAE docs state) "has
similar features to and is compatible with [memcached][] by Danga
Interactive."

GAE's documentation further states:

> The Memcache service provides your application with a high performance
> in-memory key-value cache that is accessible by multiple instances of
> your application. Memcache is useful for data that does not need the
> persistence and transactional features of the datastore, such as
> temporary data or data copied from the datastore to the cache for high
> speed access.

However, there's a limit to how much stuff you can cram into your
application's memcache area. GAE can and will evict items from memcache due
to "memory pressure" (i.e., if there's too much stuff in there). Since my
primary goal is to reduce CPU usage, rather than round-trip time to the
data store, I decided to implement a two-level cache. The primary cache is
the memcache service. The secondary cache is the data store. The theory is
that it's still "cheaper" to go to the data store cache than to re-render
the page from RST.

I also decided to remove the preview IFRAME from the edit page,
since I can always go to another browser tab or window and preview
a draft article by entering the direct URL for it. That way, it
only re-renders when I ask for it.

# The Implementation

In the remainder of this article, I'll discuss how I implemented the page
cache, using the [picoblog][] software I described in my previous article,
[Writing Blogging Software for Google App Engine][]. The modified
[picoblog][] software (as well as the original non-caching software) is
available at [http://software.clapper.org/python/picoblog/.][]

## Data Model Changes

The first change is to add the appropriate data items for the
second-level cache. In `models.py`, I added the following:

{% codeblock lang:python %}
    class PageCacheEntry(db.Model):
        """
        An entry in the database page cache.
        """
        page_key = db.StringProperty(required=True)
        page = db.TextProperty()

    class PageCache(object):
        """
        Represents the disk-based (database-based) page cache. This class is
        not persisted; it lives here because it messes with the data model.
        It represents the public face of the page cache.
        """

        def __init__(self):
            pass

        def get(self, page_key_to_find):
            q = db.Query(PageCacheEntry)
            q.filter('page_key = ', page_key_to_find)
            pages = q.fetch(1)
            logging.debug('PageCache.get("%s") -&gt; %s' % (page_key_to_find, pages))
            return pages[0].page if pages else None

        def delete(self, key):
            q = db.Query(PageCacheEntry).filter('page_key = ', key)
            pages = q.fetch(1)
            if pages:
                db.delete(pages)

        def add(self, page_key, page_contents):
            logging.debug('Adding "%s" to database-resident page cache' % page_key)
            PageCacheEntry(page_key=page_key, page=page_contents).put()

        def flush_all(self):
            q = db.Query(PageCacheEntry)
            pages = q.fetch(FETCH_THEM_ALL)
            if pages:
                for page in pages:
                    db.delete(page)
{% endcodeblock %}

The first class, `PageCacheEntry`, represents a single cached page in the
data store. The second class, `PageCache`, isn't persisted; it's the public
face of the second-level cache, and it serves as a means to manipulate the
page cache. That is, `PageCache` is the class the rest of the code will
use; no code outside of `models.py` will ever touch `PageCacheEntry`.

## The `TwoLevelCache` class

With the data model changes finished, I created a `cache.py` file
with the following code:

{% codeblock lang:python %}
    import logging

    from google.appengine.api import memcache
    from google.appengine.ext import webapp

    from models import PageCache
    import defs

    class TwoLevelCache(object):
        """
        Implements a simple two-level cache, using memcache as the primary
        cache and a database-resident page cache as the secondary cache.
        """
        def __init__(self):
            self.memcache = memcache
            self.db_cache = PageCache()

        def get(self, key):
            """
            Retrieve an object from the page cache. ``get()`` checks the
            memory cache first; if the page isn't there, it checks the
            database-resident cache. If the page is in the database cache,
            but not the memory cache, it's copied back to the memory cache.

            :Parameters:
                key : str
                    the cache key for the page

            :rtype: str
            :return: the cached page, or ``None`` if not found
            """
            # First, check memcache. If it's not there, go to the
            # database.
            page = self.memcache.get(key)
            if page is not None:
                logging.debug('Memcache hit for "%s"' % key)

            else:
                logging.debug('Memcache miss for "%s". Checking DB cache.' % key)
                page = self.db_cache.get(key)
                logging.debug('DB cache: page=%s' % page)
                if page is not None:
                    # DB cache hit. Put it in the memory cache, too.
                    logging.debug('DB cache hit for "%s"' % key)
                    if not self.memcache.set(key, page):
                        logging.error('Failed to add "%s" to memcache' % key)
                else:
                    logging.debug('Cache miss for "%s"' % key)

            return page

        def add(self, key, page):
            """
            Add a rendered page to the memory and disk caches.

            :Parameters:
                key : str
                    The cache key for the page. (The page's URL path is a good
                    key.)

                page : str
                    The rendered page to cache
            """
            self.db_cache.add(key, page)
            if not self.memcache.set(key, page):
                logging.warning('Failed to add "%s" to memcache' % key)
            return True

        def delete(self, key):
            """
            Delete a key from the cache.

            :Parameters:
                key : str
                    The cache key for the page.
            """
            self.db_cache.delete(key)
            self.memcache.delete(key)

        def flush_all(self):
            """
            Clear both the memory and disk caches.
            """
            self.memcache.flush_all()
            self.db_cache.flush_all()

        def flush_for_article(self, article, old_article):
            # If the tags changed, the tag cloud is affected. If the title
            # changed, the list of recent articles is likely to be affected.
            # Have to wipe the cache if that happens.
            #
            # NOTE: If the article is a draft, though, don't uncache everything.
            # Just uncache the article itself. No one else is going to see the
            # article, but *I* might be looking at it in another window, as I
            # compose it.

            if (not article.draft) and \
               ((article.title != old_article.title) or \
                (article.categories != old_article.categories)):
                logging.debug('Title and/or tags changed. Uncaching everything')
                self.flush_all()

            else:
                # Uncache the page for the article itself.

                path = '/' + defs.ARTICLE_URL_PATH + '/%s' % article.id
                logging.debug('Uncaching "%s"' % path)
                self.delete(path)

                if old_article.description != article.description:
                    # Uncache the main page, since the description changed and
                    # it's likely this article is on the main page.
                    logging.debug('Description changed. Uncaching "/"')
                    self.delete('/')

                    # Uncache the RSS feeds.
                    logging.debug('Description changed. Uncaching feeds.')
                    self.delete('/' + defs.ATOM_URL_PATH)
                    self.delete('/' + defs.RSS2_URL_PATH)

                # For every tag, uncache the pages for that tag.  Be sure to use
                # the current tags AND the old tags, in case some were added or
                # deleted.
                for tag in set(article.categories + old_article.categories):
                    path = '/' + defs.TAG_URL_PATH + '/%s' % tag
                    logging.debug('Uncaching "%s"' % path)
                    self.delete(path)

                # Uncache the month page.
                year, month = article.timestamp.year, article.timestamp.month
                path = '/' + defs.DATE_URL_PATH + '/%04d-%02d' % (year, month)
                logging.debug('Uncaching "%s"' % path)
                self.delete(path)
{% endcodeblock %}

`TwoLevelCache` is the actual cache used by the rest of the application.
Let's take a brief tour of each method (except `__init__()`):

### The `get()` method

`get()` retrieves an item from the cache.

* It first checks the Memcache service. If the page is there, it's returned.
* If the page is not in Memcache, then `get()` checks the data
  store-resident cache. If the page is there, then it's re-added to
  Memcache (which could fail) and returned.
* Otherwise, `get()` returns `None`.

### The `add()` method

`add()` puts a rendered page in both Memcache and the disk cache.

### The `delete()` method

`delete()` removes a page from both Memcache and the disk cache.

### The `flush_all()` method

`flush_all()` clears both caches.

### The `flush_for_article()` method

`flush_for_article()` is the most complicated method. It's called when an
article has been edited and saved, and it attempts to be intelligent about
which parts of the cache to clear. The caller passes both the changed
article *and* a copy of the article before it was changed.

The uncaching rules are relatively simple:

* If the article is not a draft, and the title or the tags have changed,
  then every rendered page could be affected. The tags appear on every
  page, and the most recent *n* article titles appear on every page. (And
  it's likely that the article being edited is a more recent one.) So, in
  this case, we clear the entire cache.
* Otherwise, uncache: the page itself, the pages of articles with the same
  tags, and the page that displays all articles in the same month as the
  changed article.

Those rules can be further refined, but they're a good start at
uncaching only what needs to be uncached.

## Changes to the Admin Code

First, as I noted above, I removed the preview frame from the edit
window. With the preview frame in place, I'm constantly paying the
penalty of re-rendering the article. It's not necessary, since I
can always look at the draft article in another window.

Removing the preview frame is a matter of removing these lines from
`templates/admin-edit.html`:

{% codeblock lang:html %}
    <h1 class="admin-page-title">Preview:</h1>
    <div style="border-top: 1px solid black">
    <iframe src="/id/{@{ article.id }@}" width="97%" scrolling="auto" height="750"
            frameborder="0">
    </iframe>
    </div>
{% endcodeblock %}

Then, I changed the `SaveArticleHandler` class in `admin.py`:

{% codeblock lang:python %}
    class SaveArticleHandler(request.BlogRequestHandler):
        """
        Handles form submissions to save an edited article.
        """
        def post(self):
            title = cgi.escape(self.request.get('title'))
            body = cgi.escape(self.request.get('content'))
            s_id = cgi.escape(self.request.get('id'))
            id = int(s_id) if s_id else None
            tags = cgi.escape(self.request.get('tags'))
            published_when = cgi.escape(self.request.get('published_when'))
            draft = cgi.escape(self.request.get('draft'))
            if tags:
                tags = [t.strip() for t in tags.split(',')]
            else:
                tags = []
            tags = Article.convert_string_tags(tags)

            if not draft:
                draft = False
            else:
                draft = (draft.lower() == 'on')

            article = Article.get(id) if id else None
            if article:
                # It's an edit of an existing item.

                old_article = copy.deepcopy(article)
                article.title = title
                article.body = body
                article.tags = tags
                article.draft = draft
            else:
                # It's new.
                article = Article(title=title,
                                  body=body,
                                  tags=tags,
                                  draft=draft)
                old_article=Article(title='', tags=[], body='')

            article.save()
            self.cache.flush_for_article(article, old_article)

            edit_again = cgi.escape(self.request.get('edit_again'))
            edit_again = edit_again and (edit_again.lower() == 'true')
            if edit_again:
                self.redirect('/admin/article/edit/?id=%s' % id)
            else:
                self.redirect('/admin/')
{% endcodeblock %}

These changes ensure that saving an article adjusts the cache
appropriately. The `copy.deepycopy()` method comes from the
standard Python `copy` module.

## Changes to `blog.py`

Finally, I had to change the main request handlers in `blog.py` to
use the cache.

All handlers in `blog.py` already extend an `AbstractPageHandler` class.
The necessary changes break down into just a few things:

* Add a `get()` method to `AbstractPageHandler`. This method will attempt
  to fetch the page from the cache, based on its unique path. If the page
  isn't in the cache, `get()` will call out to the subclass's `do_get()`
  method to render the page; then, it'll cache the newly-rendered page.

* Rename all the subclasses' `get()` methods to `do_get()`, and change
  those methods to return the rendered page instead of writing it directly
  to the HTTP response object.

* Add a `status()` method that subclasses can override to set the HTTP
  status to something other than 200. This is mostly for the
  `NotFoundPageHandler`.

Here's the new `get()` method and `status()` method in
`AbstractPageHandler`:

{% codeblock lang:python %}
    class AbstractPageHandler(request.BlogRequestHandler):
        """
        Abstract base class for all handlers in this module. Basically,
        this class exists to consolidate common logic.
        """
        @property
        def status(self):
            return None

        def get(self, *args):
            path = self.request.environ['PATH_INFO']
            page = self.cache.get(path)
            if page is None:
                # Not in the cache. Build it, then cache it.
                page = self.do_get(*args)
                logging.debug('Caching "%s"' % path)
                if not self.cache.add(path, page):
                    logging.error('Failed to cache page "%s"' % path)

            self.response.out.write(page)
            http_status = self.status
            if http_status:
                self.response.set_status(http_status)
{% endcodeblock %}

Both are pretty straightforward.

Let's look at just one of the handlers to show the changes that
need to be made; the same change needs to be made to all handlers.
The `RSS2FeedHandler` class is nice and small, so I'll use that
one.

Here's how `RSS2FeedHandler` looked before caching:

{% codeblock lang:python %}
    class RSSFeedHandler(AbstractPageHandler):
        """
        Handles request for an RSS2 feed of the blog's contents.
        """
        def get(self):
            articles = Article.published()
            self.response.headers['Content-Type'] = 'text/xml' 
            self.response.out.write(self.render_articles(articles,
                                                         self.request,
                                                         [],
                                                         'rss2.xml'))
{% endcodeblock %}

Here's how it looks now:

{% codeblock lang:python %}
    class RSSFeedHandler(AbstractPageHandler):
        """
        Handles request for an RSS2 feed of the blog's contents.
        """
        def do_get(self):
            articles = Article.published()
            self.response.headers['Content-Type'] = 'text/xml'
            return self.render_articles(articles, self.request, [], 'rss2.xml')
{% endcodeblock %}

The only handler that's even slightly different is the `NotFoundPageHandler`:

{% codeblock lang:python %}
    class NotFoundPageHandler(AbstractPageHandler):
        """
        Handles pages that aren't found.
        """
        @property
        def status(self):
            return 404

        def do_get(self):
            return self.render_articles([], self.request, [], 'not-found.html')
{% endcodeblock %}

Note the addition of the `status()` method, returning a 404 ("not found")
HTTP code.

That's it. The blogging software now has a two-level page cache.

# Did it help?

Based on profiling data, adding the page cache helped a lot. But,
just as important, the blog now seems much more responsive, and
there are far fewer "high CPU" warning messages in the log.

# The Code

As noted above, the modified [picoblog][] software (as well as the original
non-caching software) is available at
[http://software.clapper.org/python/picoblog/.][]

# Disclaimer

There are certainly other caching implementations and approaches one could
use. For instance, my friend and colleague, [Mark Chadwick][], added
caching to *his* GAE application using a [python decorator][]; his code
caches anything that a decorated function happens to return. The approach I
outline in this article is just one implementation--one that happens to
work well for me.

# Related Brizzled Articles

* [Writing Blogging Software for Google App Engine][]
* [Making XML-RPC calls from a Google App Engine application][]

# Additional Reading

* [Experimenting with Google App Engine][], by Bret Taylor.
* [Building Scalable Web Applications with Google App Engine][]
  (presentation), by Google's Brett Slatkin.
* [Google App Engine documentation][]

[previous article]: /id/77/
[App Engine]: http://appengine.google.com/
[previous article]: /id/77/
[reStructuredText]: http://docutils.sourceforge.net/rst.html
[profiled]: http://code.google.com/appengine/kb/commontasks.html#profiling
[memory cache API]: http://code.google.com/appengine/docs/memcache/
[memcached]: http://www.danga.com/memcached/
[picoblog]: http://software.clapper.org/python/picoblog/
[Writing Blogging Software for Google App Engine]: /id/77
[picoblog]: http://software.clapper.org/python/picoblog/
[http://software.clapper.org/python/picoblog/.]: http://software.clapper.org/python/picoblog/.
[picoblog]: http://software.clapper.org/python/picoblog/
[http://software.clapper.org/python/picoblog/.]: http://software.clapper.org/python/picoblog/.
[Mark Chadwick]: http://hipstersinc.com/
[python decorator]: http://www.python.org/dev/peps/pep-0318/
[Writing Blogging Software for Google App Engine]: /id/77/
[Making XML-RPC calls from a Google App Engine application]: /id/80/
[Experimenting with Google App Engine]: http://bret.appspot.com/entry/experimenting-google-app-engine
[Building Scalable Web Applications with Google App Engine]: http://sites.google.com/site/io/building-scalable-web-applications-with-google-app-engine
[Google App Engine documentation]: http://code.google.com/appengine/docs/
