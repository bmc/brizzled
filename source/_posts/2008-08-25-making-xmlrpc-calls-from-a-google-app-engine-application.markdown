---
layout: post
comments: true
title: "Making XML-RPC calls from a Google App Engine application"
date: 2008-08-25 00:00
categories: [python, App Engine, programming, XML RPC]
toc: true
---

# Introduction

Google [App Engine][] (GAE) is a useful platform on which to develop
Python-based web applications. But a GAE application runs in a [sandbox][]
that prevents it from opening a socket, which makes the standard Python
`xmlrpclib` module inoperable.

Fortunately, there's a simple solution to this problem.

This article is broken into several parts: First, I discuss the code that's
necessary to get `xmlrpclib` to work within a GAE application. Then, I show
how to enhance [picoblog][], the sample GAE blogging engine I developed for
my [Writing Blogging Software for Google App Engine][] article, so that it
can send a "ping" to [Technorati][] when a new article is published.

<!-- more -->

# Getting XML-RPC to work with GAE

## A Quick Overview of `xmlrpclib`

It's entirely possible to do XML-RPC without the benefit of the standard
Python `xmlrpclib` module. But `xmlrpclib` makes things so much simpler
that it'd be nice to use it. Doing the job manually means building an XML
message, sending it to the remote HTTP server, reading the result XML, and
parsing that XML. `xmlrpclib` already does all that. But `xmlrpclib`
attempts to open a socket to connect to the remote HTTP server, and opening
a socket is strictly forbidden by the GAE [sandbox][].

Ideally, we want to use `xmlrpclib`, but have it connect to the remote HTTP
server using the [fetch()][] function provided by the
`google.appengine.api.urlfetch` module. We *could* create our own hacked
version of `xmlrpclib` to do just that, but, luckily, the authors of
`xmlrpclib` thought ahead and made the library easy to extend.

### Sample XML-RPC call

Typically, making an XML-RPC call through `xmlrpclib` requires code
like this:

{% codeblock lang:python %}
rpc_server = xmlrpclib.ServerProxy('http://rpc.technorati.com/rpc/ping')
result = rpc_server.weblogUpdates.ping('My Blog Name', 
                                       'http://picoblog.example.com/')
# The result is dictionary. In Technorati's case, we have to check the
# flerror element.
if result.get('flerror', False) == True:
    logging.error('Technorati ping error from server: %s' %
                  result.get('message', '(No message in RPC result)'))
else:
    logging.debug('Technorati ping successful.')
{% endcodeblock %}

There are a couple things going on here. The first line of code sets up a
`ServerProxy` object that allows us to interact with the remote RPC server.
The actual method call looks just like a method call. The `xmlrpclib`
module translates this line of code:

{% codeblock lang:python %}
result = rpc_server.weblogUpdates.ping('My Blog Name', 'http://picoblog.example.com/')
{% endcodeblock %}

into the following chunk of XML, which it then sends to the remote
web server:

{% codeblock lang:xml %}
<?xml version="1.0"?>
<methodCall>
  <methodName>weblogUpdates.ping</methodName>
  <params>
    <param>
      <value>My Blog Name</value>
    </param>
    <param>
      <value>http://picoblog.example.com/</value>
    </param>
  </params>
</methodCall>
{% endcodeblock %}

It then waits for the XML-RPC response and decodes it into a
dictionary of name-value pairs. Just for completeness, here's the
successful result from a Technorati ping:

{% codeblock lang:xml %}
<?xml version="1.0" encoding="UTF-8"?>
<methodResponse>
    <params>
        <param>
            <value>
                <struct>
                    <member>
                        <name>flerror</name>
                        <value><boolean>0</boolean></value>
                    </member>
                    <member>
                        <name>message</name>
                        <value><string>Thanks for the ping</string></value>
                    </member>
                </struct>
            </value>
        </param>
    </params>
</methodResponse>
{% endcodeblock %}

And here's the failure result:

{% codeblock lang:xml %}
<?xml version="1.0" encoding="UTF-8"?>
<methodResponse>
    <params>
        <param>
            <value>
                <struct>
                    <member>
                        <name>flerror</name>
                        <value><boolean>0</boolean></value>
                    </member>
                    <member>
                        <name>message</name>
                        <value>
                            <string>You just sent a ping, please only
                            ping when you update </string>
                        </value>
                    </member>
                </struct>
            </value>
        </param>
    </params>
</methodResponse>
{% endcodeblock %}

## `xmlrpclib` Transport Classes

As written, the code, above, won't work, because `xmlrpclib`
attempts to create a socket to connect to the web server, and GAE's
[sandbox][]
forbids creating sockets.

However, under the covers, `xmlrpclib` uses special *transport*
objects to make the connections to the remote HTTP server. The
standard transport object is an instance of the
`xmlrpclib.Transport` class; you can examine that class by looking
at the
[xmlrpclib.py source code][]
in your Python distribution. Here's a portion of that class; the
method we care about is `request()`:

{% codeblock lang:python %}
class Transport:
    """Handles an HTTP transaction to an XML-RPC server."""

    user_agent = "xmlrpclib.py/%s (by www.pythonware.com)" % __version__

    def __init__(self, use_datetime=0):
        self._use_datetime = use_datetime

    def request(self, host, handler, request_body, verbose=0):
        # issue XML-RPC request

        h = self.make_connection(host)
        if verbose:
            h.set_debuglevel(1)

        self.send_request(h, handler, request_body)
        self.send_host(h, host)
        self.send_user_agent(h)
        self.send_content(h, request_body)

        errcode, errmsg, headers = h.getreply()

        if errcode != 200:
            raise ProtocolError(
                host + handler,
                errcode, errmsg,
                headers
                )

        self.verbose = verbose

        try:
            sock = h._conn.sock
        except AttributeError:
            sock = None

        return self._parse_response(h.getfile(), sock)

    def getparser(self):
        # get parser and unmarshaller
        return getparser(use_datetime=self._use_datetime)

    def _parse_response(self, file, sock):
        # read response from input file/socket, and parse it

        p, u = self.getparser()

        while 1:
            if sock:
                response = sock.recv(1024)
            else:
                response = file.read(1024)
            if not response:
                break
            if self.verbose:
                print "body:", repr(response)
            p.feed(response)

        file.close()
        p.close()

        return u.close()
{% endcodeblock %}

The class is considerably larger than that, but `request()` is the
only method that's required by the interface.

As it happens, the `ServerProxy` class lets us pass in our own
transport object; if we don't supply one, it uses its `Transport`
object (if the connection is not an SSL connection). This is the
key to our GAE solution.

## The `GAEXMLRPCTransport` class

We can create our own transport class that uses the
`google.appengine.api.urlfetch` module's
[fetch()][]
method instead of standard socket access. That class turns out to
be pretty simple:

{% codeblock lang:python %}
import sys
import xmlrpclib
import logging

from google.appengine.api import urlfetch

class GAEXMLRPCTransport(object):
    """Handles an HTTP transaction to an XML-RPC server."""

    def __init__(self):
        pass

    def request(self, host, handler, request_body, verbose=0):
        result = None
        url = 'http://%s%s' % (host, handler)
        try:
            response = urlfetch.fetch(url,
                                      payload=request_body,
                                      method=urlfetch.POST,
                                      headers={'Content-Type': 'text/xml'})
        except:
            msg = 'Failed to fetch %s' % url
            logging.error(msg)
            raise xmlrpclib.ProtocolError(host + handler, 500, msg, {})

        if response.status_code != 200:
            logging.error('%s returned status code %s' % 
                          (url, response.status_code))
            raise xmlrpclib.ProtocolError(host + handler,
                                          response.status_code,
                                          "",
                                          response.headers)
        else:
            result = self.__parse_response(response.content)

        return result

    def __parse_response(self, response_body):
        p, u = xmlrpclib.getparser(use_datetime=False)
        p.feed(response_body)
        return u.close()
{% endcodeblock %}

There are several things to note about the `request()` method.

* It uses the `fetch()` method from the GAE API.
* It scrupulously raises `xmlrpclib` exceptions on error conditions.
* It uses `xmlrpclib` function `getparser()` to parse the result. Unlike
  the response parsing logic in the `xmlrpclib.Transport` class, ours is
  much simpler, since it has the entire response in hand and doesn't have
  to read it a bufferful at a time.

Using the `GAEXMLRPCTransport()` class, we can now make our XML-RPC
client code work within GAE:

{% codeblock lang:python %}
rpc_server = xmlrpclib.ServerProxy('http://rpc.technorati.com/rpc/ping',
                                   GAEXMLRPCTransport())
result = rpc_server.weblogUpdates.ping('My Blog Name', 
                                       'http://picoblog.example.com/')
# The result is dictionary. In Technorati's case, we have to check the
# flerror element.
if result.get('flerror', False) == True:
    logging.error('Technorati ping error from server: %s' %
                  result.get('message', '(No message in RPC result)'))
else:
    logging.debug('Technorati ping successful.')
{% endcodeblock %}

# Changes to `picoblog`

Finally, as a proof of concept, let's change the `picoblog`
software (see \`Related Brizzled Articles\`\_, below) to ping
Technorati whenever an article is published for the first time.

## New `xmlrpc.py` module

First, put the `GAEXMLRPCTransport` class in its own `xmlrpc.py`
file, and put that file at the root of the `picoblog` source tree.

## Changes to `defs.py`

Next, we add a few things to the `defs.py` module:

{% codeblock lang:python %}
CANONICAL_BLOG_URL = 'http://picoblog.appspot.com/'

import os
_server_software = os.environ.get('SERVER_SOFTWARE','').lower()
if _server_software.startswith('goog'):
    ON_GAE = True
else:
    ON_GAE = False
del _server_software
{% endcodeblock %}

The `CANONICAL_BLOG_URL` constant defines the URL of our blog; we
have to include that information in the Technorati ping. (We
*could* figure that out from the request that posts the article to
be saved, but using a constant is simpler for now.) The second
block of code sets `ON_GAE` to `True` if we're running on App
Engine, and `False` if we're running within the local development
server. During tests on the development server, we'll ping a fake
URL; see below.

## Changes to `admin.py`

### `SaveArticleHandler`

The bulk of the changes are in the `admin.py` module. First, we have to
modify the `SaveArticleHandler` class to detect when an article is
published and notify Technorati when that happens. (GAE invokes an instance
of the `SaveArticleHandler` class to process the "save article" action.)
We'll use a simple definition of "published": When the "draft" flag is
cleared.

Here's the new version of `SaveArticleHandler`:

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
            just_published = article.draft and (not draft)
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
            just_published = not draft

        article.save()

        if just_published:
            logging.debug('Article %d just went from draft to published. '
                          'Alerting the media.' % article.id)
            alert_the_media()

        edit_again = cgi.escape(self.request.get('edit_again'))
        edit_again = edit_again and (edit_again.lower() == 'true')
        if edit_again:
            self.redirect('/admin/article/edit/?id=%s' % article.id)
        else:
            self.redirect('/admin/')
{% endcodeblock %}

Here are the relevant changes:

{% codeblock lang:python %}
article = Article.get(id) if id else None
if article:
    # It's an edit of an existing item.
    just_published = article.draft and (not draft)
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
    just_published = not draft

...

if just_published:
    logging.debug('Article %d just went from draft to published. '
                  'Alerting the media.' % article.id)
    alert_the_media()
{% endcodeblock %}

Determining that the article was just published is trivial. If it *has*
just been published, we call a (new) `alert_the_media()` function.

### The `alert_the_media()` function

This function sends the appropriate alerts to whichever external web sites
we think should hear about new articles. Currently, that's only Technorati,
but we might want to add more later, so it doesn't hurt to put this logic
in a separate function.

The `alert_the_media()` function is simple enough:

{% codeblock lang:python %}
def alert_the_media():
    # Right now, we only alert Technorati
    ping_technorati()
{% endcodeblock %}

### The `ping_technorati()` function

Finally, we get to the function that *uses* our XML-RPC coolness.
It's not a whole lot different from the \`sample XML-RPC call\`\_
at the top of the article:

{% codeblock lang:python %}
def ping_technorati():
    if defs.ON_GAE:
        url = TECHNORATI_PING_RPC_URL
    else:
        url = FAKE_TECHNORATI_PING_RPC_URL

    logging.debug('Pinging Technorati at: %s' % url)
    try:
        transport = xmlrpc.GoogleXMLRPCTransport()
        rpc_server = xmlrpclib.ServerProxy(url, transport=transport)
        result = rpc_server.weblogUpdates.ping(defs.BLOG_NAME,
                                               defs.CANONICAL_BLOG_URL)
        if result.get('flerror', False) == True:
            logging.error('Technorati ping error from server: %s' %
                          result.get('message', '(No message in RPC result)'))
        else:
            logging.debug('Technorati ping successful.')
    except:
        raise urlfetch.DownloadError, \
              "Can't ping Technorati: %s" % sys.exc_info()[1]
{% endcodeblock %}

Note the first four lines, though. They say:

* If we're running on GAE, use the real Technorati ping URL.
* Otherwise, use a fake one.

Those constants are defined at the top of `admin.py`:

{% codeblock lang:python %}
TECHNORATI_PING_RPC_URL = 'http://rpc.technorati.com/rpc/ping'
FAKE_TECHNORATI_PING_RPC_URL = 'http://localhost/~bmc/technorati-mock.xml'
{% endcodeblock %}

The fake URL is nothing more than a canned page. On my development
machine, I run an instance of the
[Apache HTTP server][]. In my personal
web page area, I created a static XML file containing the canned
result of a Technorati ping. (See above.) That way, I can test the
XML-RPC logic without actually pinging Technorati for real.

And that's all there is to it.

# Potential Problems

Note that XML-RPC calls can fail for several reasons, including:

1. The XML-RPC response is too large. GAE defines a `ResponseTooLargeError`
   that is sent when the response data exceeds the maximum allowed size and
   the `allow_truncated` parameter passed to [fetch()][] was `False`.
   Passing `allow_truncated=True` to [fetch()][] isn't especially helpful,
   so there isn't much we can do about this error.
2. The remote HTTP server takes too long to respond. There's not much we
   can do about this error.

# Getting the Code

The code used in this article is available at
[http://software.clapper.org/python/picoblog/][].

# Related Brizzled Articles

* [Writing Blogging Software for Google App Engine][]
* [Adding Page caching to a GAE application][]

# Additional Reading

* [XML-RPC HOWTO][]
* The [xmlrpclib.py source code][]
* The [xmlrpclib documentation][]
* [Building Scalable Web Applications with Google App Engine][]
  (presentation), by Google's Brett Slatkin.
* [Google App Engine documentation][]

[App Engine]: http://appengine.google.com/
[sandbox]: http://code.google.com/appengine/docs/python/sandbox.html
[picoblog]: http://software.clapper.org/python/picoblog/
[Writing Blogging Software for Google App Engine]: http://brizzled.clapper.org/id/77
[Technorati]: http://www.technorati.com/
[sandbox]: http://code.google.com/appengine/docs/python/sandbox.html
[xmlrpclib.py source code]: http://svn.python.org/projects/python/trunk/Lib/xmlrpclib.py
[Apache HTTP server]: http://www.apache.org/httpd/
[fetch()]: http://code.google.com/appengine/docs/urlfetch/fetchfunction.html
[http://software.clapper.org/python/picoblog/]: http://software.clapper.org/python/picoblog/
[Writing Blogging Software for Google App Engine]: /id/77/
[Adding Page caching to a GAE application]: id/78/
[XML-RPC HOWTO]: http://www.tldp.org/HOWTO/XML-RPC-HOWTO/index.html
[xmlrpclib.py source code]: http://svn.python.org/projects/python/trunk/Lib/xmlrpclib.py
[xmlrpclib documentation]: http://docs.python.org/lib/module-xmlrpclib.html
[Building Scalable Web Applications with Google App Engine]: http://sites.google.com/site/io/building-scalable-web-applications-with-google-app-engine
[Google App Engine documentation]: http://code.google.com/appengine/docs/
