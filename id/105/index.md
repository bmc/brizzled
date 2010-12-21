---
layout: article
title: Some Jekyll Hacks
tags: jekyll, ruby, blogging, liquid
date: 2010-12-20
toc: toc
---

# Introduction

I use [Jekyll][] to generate this blog (in addition to the
[clapper.org web site][] and my [company web site][]). This blog presented
a few challenges, which I was able to address with some simple, if
[crufty][], Jekyll hacks. The hacks are all accomplished via Jekyll
[plugins][] and [monkeypatching][], and they work with Jekyll 0.8.0. (I
haven't tested them with other versions.)

# Non-standard Blog Layout

For [historical reasons][], this blog uses a layout that doesn't match
Jekyll's blog-specific [post format][]. Each article has a unique numeric
ID, which corresponds to a subdirectory of a top -level `id` directory. For
instance, this article, and any related files, live in source directory
`id/105/`; the article's source is in file `index.md`.

So, the first problem to be solved is to ensure that Jekyll finds and
renders the blog's articles. The solution is fairly simple. Underneath the
top level of my blog source, I created a `_plugins` directory; that's where
Jekyll expects to find its [plugins][], which must be [Ruby][] code. Within
that directory, I created a `site.rb` file, containing code that augments
the stock Jekyll `Site` class:

{% highlight ruby %}
    module Jekyll

      # Extensions to the Jekyll Site class.

      class Site
      
        # Regular expression by which blog posts are recognized
        POST_PAGE_RE = /\/id\/[0-9]+\/index.html/

        # Find my blog posts among all the pages.
        def blog_posts
            self.pages.select {|p| p.full_url =~ POST_PAGE_RE}
        end

        # Add some custom options to the site payload, accessible via the
        # "site" variable within templates.
        #
        # articles - blog articles, in reverse chronological order
        # max_recent - maximum number of recent articles to display
        alias orig_site_payload site_payload
        def site_payload
            h = orig_site_payload
            payload = h["site"]
            payload["articles"] = blog_posts.sort {|p1, p2| p2.date <=> p1.date}
            payload["max_recent"] = payload.fetch("max_recent", 15)
            h["site"] = payload
            h
        end
      end
    end
{% endhighlight %}

That code does two things:

* It adds a `blog_posts` method that returns the Jekyll `Page` objects
  that correspond to my blog posts.
* It augments the stock Jekyll `Site::site_payload` method to add the list
  of blog posts (and some other information) to the site payload, thus making
  them available to the [Liquid][] templates.

There's another piece of code that's required, in a file called
`_plugins/page.rb`:

{% highlight ruby %}
    module Jekyll

      # Extensions to the Jekyll Page class.

      class Page
      
        # Full URL of the page.
        def full_url
            File.join(@dir, self.url)
        end

        alias orig_to_liquid to_liquid
        def to_liquid
            h = orig_to_liquid
            h['max_top'] = (self.data['max_top'] ||
                            site.config['max_top'] ||
                            15)
            h['date'] = self.date
            h
        end
      end
    end
{% endhighlight %}

This code adds a `Page.full_url` method that guarantees to return the full
URL path. I added that method, because I noticed that calling `Page.url`
returns only a partial path, and I need the full path in various
places, including within my `Site.blog_posts` method.

The code also chains the `to_liquid` method, to augment the hash table of
data available to the Liquid template, when a page is being rendered. The
custom version of `to_liquid` adds the following values:

`date`:
:  Because my blog articles don't have a date in the file name, I have to be
   able to specify the publication date somewhere. I do so via the `date`
   variable in the [YAML front matter][]. The code ensures that the parsed
   date is available to the Liquid template.

`max_top`:
:  `max_top` controls the number of articles shown on the summary (top) page
   of the blog. The code uses the the value of `max_top` from the page's
   [YAML front matter][], if it's present. (Realistically, this value
   will only appear in the [Markdown][] source for the top page.) If
   `max_top` isn't in the front matter, then the code tries to find it in
   the `_config.yml` data. If it's not there either, then `to_liquid` uses
   a default value of 15.

With those two monkeypatched hacks in place, I can now use code like the
following in my layouts:

    {\% for article in site.articles limit:page.max_top \%}

        <h1>\{\{ article.title \}\}</h1>

        ...

    {\% endfor \%}

# Liquid and Django

The article entitled [*Writing Blogging Software for Google App Engine*][77]
contains [App Engine template][] markup (which is based on
[Django template][] markup). These sequences confuse the [Liquid][]
template engine Jekyll uses, because they look similar to Liquid's template
language. For example, the occurrence of a block of markup like this:

    {\% block main \%}
    {\% endblock \%}
    
can cause Liquid to throw an exception about a bad tag ("block"). Similarly,
something like this:

    \{\{ blog.name \}\}

can result in an empty line, because Liquid will attempt to substitute the
value of `blog.name`, only to find it *has* no value.

I needed to add a means of escaping those tags, so that Liquid would ignore
them. The solution is straightforward and involves some more monkeypatching
to Jekyll's `Page` class:

{% highlight ruby %}
    module Jekyll

      # Extensions to the Jekyll Page class.

      class Page
      
        # Chained version of render() method. This version takes the
        # output (from self.output) and "fixes" escaped Liquid
        # strings, allowing Liquid markup to be escaped, for display.
        alias orig_render render
        def render(layouts, site_payload)
            res = orig_render(layouts, site_payload)
            self.output = fix_liquid_escapes(self.output)
            res
        end

        def fix_liquid_escapes(s)
            s.gsub!('\\{\\{', '\{\{')
            s.gsub!('\\}\\}', '\}\}')
            s.gsub!('\\%', '\%')
            s.gsub!("\\\\\\\\", "\\\\")
            s
        end
      end
    end
{% endhighlight %}

In that small bit of code, I've replaced the Jekyll `Page.render()` method
with my own version of that method, which first invokes the actual Jekyll
`Page.render()` method, then replaces escaped Liquid tags with their actual
tags.

This hack allows me to represent Liquid (or [Django][]) template markup
within my Markdown blog articles like this:

    {\\% block main \\%}
    {\\% endblock \\%}
    

    \\{\\{ article.path \\}\\}

The backslash escapes cause Liquid to ignore the tags when it renders my
articles. The `fix_liquid_escapes` hack then converts the escaped sequences
into the actual sequences, so they look correct in the rendered page.

# Tags

Since my articles aren't Jekyll posts, I can't easily make use of Jekyll's
built-in support for post categories. It seemed easier just to roll my own.
I had several goals in mind:

1. Be able to specify one or more tags for each page.
2. Allow the layout for an individual page to be able to see the page's tags.
3. Be able to find all pages associated with a particular tag.
4. Generate a page for each tag, with links to the articles associated with
   the tag.

## Goal 1: Be able to specify one or more tags for each page.

Addressing the first goal was simple: I just specify a comma-separated list of
tags in an article's [YAML front matter][]. For instance:

    ---
    layout: article
    title: Some Jekyll Hacks
    tags: jekyll, ruby, blogging, liquid
    ---

## Goal 2: Allow the layout for a page to be able to see the page's tags

To make the tags available to the page, I first modified my `_plugins/page.rb`
file, to monkeypatch a `tags` method into the `Page` class:

{% highlight ruby %}
    module Jekyll
      class Page

        ...

        def tags
          (self.data['tags'] || '').split(',').map {|t| Tag.new(t)}
        end
      end
    end
{% endhighlight %}

This `tags` method returns a list of `Tag` objects, one for each tag. The
`Tag` class looks like this:

{% highlight ruby %}
    module Jekyll

      TAG_NAME_MAP = {
        "#"  => "sharp",
        "/"  => "slash",
        "\\" => "backslash",
        "."  => "dot",
        "+"  => "plus",
        " "  => "-"
      }

      # Holds tag information
      class Tag

        attr_accessor :dir, :name

        def initialize(name)
          @name = name.downcase.strip
          @dir = name_to_dir(@name)
        end

        def to_s
          @name
        end

        def eql?(tag)
          self.class.equal?(tag.class) && (name == tag.name)
        end

        def hash
          name.hash
        end

        def <=>(o)
          self.class == o.class ? (self.name <=> o.name) : nil
        end

        def inspect
          self.class.name + "[" + @name + ", " + @dir + "]"
        end

        def to_liquid
          # Liquid wants a hash, not an object.

          { "name" => @name, "dir" => @dir }
        end

        # Sort a list of tags by name.
        def self.sort(tags)
          tags.sort { |t1, t2| t1 <=> t2 }
        end

        private

        # Map a tag to its directory name. Certain characters are escaped,
        # using the TAG_NAME_MAP constant, above.
        def name_to_dir(name)
          s = ""
          name.each_char do |c|
            if (c =~ /[-A-Za-z0-9_]/) != nil
              s += c
            else
              c2 = TAG_NAME_MAP[c]
              if not c2
                msg = "Bad character '#{c}' in tag '#{name}'"
                puts("*** #{msg}")
                raise FatalException.new(msg)
              end
              s += c2
            end
          end
          s
        end
      end
    end
{% endhighlight %}

A `Tag` object serves several purposes:

* It normalizes tag names (converting them to lower case, stripping blanks, etc.)
* It allows tags to be easily compared and hashed.
* It converts a tag to a Liquid hash.
* It contains a method to map a tag name into a suitable directory name,
  converting illegal file characters into something more useful. For instance,
  tag "C#" ends up corresponding to directory "csharp", since "#" is an invalid
  character in a directory name.

## Goal 3: Be able to find all pages associated with a particular tag.

To accomplish this goal, I monkeypatched the following method into the Jekyll
`Site` class, via my `_plugins/site.rb` file:

{% highlight ruby %}
    module Jekyll
      class Site

        ...
        
        def pages_by_tag
          tag_ref = {}
          self.pages.each do |page|
            page.tags.each do |tag|
              pages = tag_ref.fetch(tag, Set.new)
              pages << page
              tag_ref[tag] = pages
            end
          end
          tag_ref
        end
      end
    end
{% endhighlight %}

The `pages_by_tag` method returns a hash, where each key is a `Tag` object, and
each value is a set of `Page` objects that are associated with the hash.

## Goal 4: Generate a page for each tag

A Jekyll generator plugin (see the Jekyll [plugins][] page) solved this
problem for me. Using the code at <https://gist.github.com/524748> as a
model, I wrote the following code, which I placed in `_plugins/tags.rb`:

{% highlight ruby %}
    # _plugins/tags.rb

    module Jekyll

      # A version of a page that represents a tag index.

      class TagIndex < Page
        def initialize(site, base, dir, tag, articles)
          @site = site
          @base = base
          @dir = dir
          @name = 'index.html'
          self.process(@name)
          tag_index = (site.config['tag_index_layout'] || 'tag_index') + '.html'
          self.read_yaml(File.join(base, '_layouts'), tag_index)
          self.data['tag'] = tag
          self.data['articles'] = articles.sort { |p1, p2| p1.date <=> p2.date }
          tag_title_prefix = site.config['tag_title_prefix'] || 'Tag: '
          self.data['title'] = "#{tag_title_prefix}#{tag}"
          @summary = Summary.empty
        end
      end

      class TagGenerator < Generator
        safe true

        def generate(site)
          if site.layouts.key? 'tag_index'
            dir = site.config['tag_dir'] || 'tags'
            tags = site.pages_by_tag
            tags.keys.sort {|k1, k2| k1 <=> k2}.each do |tag|
              write_tag_index(site, File.join(dir, tag.dir), tag,
                              tags[tag].to_a.sort {|t1, t2| t1.name <=> t2.name})
            end
          end
        end

        def write_tag_index(site, dir, tag, articles)
          index = TagIndex.new(site, site.source, dir, tag, articles)
          index.render(site.layouts, site.site_payload)
          index.write(site.dest)
        end
      end
    end
{% endhighlight %}

Jekyll runs the generator toward the beginning of its processing. The
`TagGenerator` class only runs if there's a `_layouts/tag_index.html`
layout. If it finds that layout, `TagGenerator` creates a directory for
each tag, under `_site/tags`, and uses the `tag_index.html` layout to
create an `index.html` file for the tag. The articles associated with each
tag appear in the `page.articles` template variable.

My version of `tag_index.html` looks a lot like the [top-level page template][]:

    {\% include top.html \%}

    <div id="articles-box">
    <div id="articles-container">

    {\% assign sep = false \%}
    {\% for article in page.articles \%}

    {\% if sep \%}
    <hr/>
    {\% endif \%}

    {\% include summary-entry.html \%}

    {\% assign sep = true \%}
    {\% endfor \%}

    {\% include bottom.html \%}

    </div>
    </div>

# Printer-friendly Pages

I believe blogs should provide printer-friendly formats, and this blog is
no exception. However, generating a printer-friendly version of each
article isn't something stock Jekyll can do. By default, Jekyll generates a
single HTML file from the combination of a layout (template) and a markup
article. Generating two HTML files from the same input article requires
some customizing.

The first piece of code is a new `PrintablePage` class, stored in
`_plugins/printable_page.rb`. A `PrintablePage` object
[delegates][Ruby delegates] most of its work to an existing `Page` object,
but it overrides a few things:

{% highlight ruby %}
  require 'delegate'

  module Jekyll
    class PrintablePage < DelegateClass(Page)

      def initialize(page)
        @real_page = page
        @dir = page.dir
        @base = page.base
        @name = page.name
        @site = page.site

        super(@real_page)
        self.data = @real_page.data.clone
        self.data['layout'] = @site.config['printable_layout'] || 'printable'
        @printable_html = @site.config['printable_html'] || 'printable.html'
      end

      def url
          self.full_url
      end

      # Hack
      def write(dest_prefix, dest_suffix = nil)
        dest = File.join(dest_prefix, @real_page.dir)
        dest = File.join(dest, dest_suffix) if dest_suffix

        # The url needs to be unescaped in order to preserve the
        # correct filename

        path = File.join(dest, CGI.unescape(self.url))
        if self.url =~ /\/$/
            FileUtils.mkdir_p(path)
            path = File.join(path, "index.html")
        end

        path.sub!('index.html', @printable_html)
        File.open(path, 'w') do |f|
            f.write(self.output)
        end
      end
    end 
  end
{% endhighlight %}

Basically, a `PrintablePage` wraps a `Page`, but makes the following changes:

1. It changes the associated layout to the name of the layout specified by
   `printable_layout` in the `_config.yml` file (defaulting to "printable").
2. It arranges to write its output to the file named by `printable_html` in
   `_config.yml` (defaulting to "printable.html"). The printer-friendly HTML
   output is written in the same directory as the regular output for the page.

The second change requires a hack to the stock Jekyll's `Page.write()`
function. This version of `write()` is identical to the one in Jekyll's
source, except for the addition of this line of code:

{% highlight ruby %}
    path.sub!('index.html', @printable_html)
{% endhighlight %}

Because the standard `Page.write()` method doesn't provide any way to
override the path generation logic, I had to clone and hack the whole
method. In the future, if Jekyll is extended to resolve the name of the
output file via a separate method, I will get rid of this hacked `write()`
method and override only that new call-out method.

There's a piece missing, though: `PrintablePage` does a nice job of
representing a printable version for a page, but some piece of code has to
cause `PrintablePage` objects to be created. A little more monkeypatching
of the Jekyll `Site` class accomplishes that goal:

{% highlight ruby %}
    module Jekyll
      class Site

        ...
        
        alias orig_write write
        def write
          orig_write

          puts('Writing printable pages')
          blog_posts.each do |page|
            printable_page = PrintablePage.new(page)
            printable_page.render(self.layouts, site_payload)
            printable_page.write(self.dest)
          end
        end
      end
    end
{% endhighlight %}

With that code in place, Jekyll will generate a printable version of each
blog post, alongside the regular version.

# Article Summaries

If you visit the [top page](/) of my blog, or [any tag page](/tags/blogging/),
you'll see that each article title is accompanied by a short summary. Those
summaries are the result of one final Jekyll hack.

To create a summary, I create a `summary.md` file in the same directory as
the blog article. Unlike the article itself, this summary Markdown file
contains no [YAML front matter][]; it's just a plain file. Thus, Jekyll
will simply copy the file to its appropriate `_site` directory, instead of
processing it. While that isn't exactly what I want, there's no harm in
allowing Jekyll to copy the file.

However, I *really* want Jekyll to convert the file into HTML, which I can
use, inline, in my layouts. To get that to happen, I monkeypatched yet again.
First, I created a `_plugins/summary.rb` file, containing a `Summary` class.
You can see the entire class
[here](https://github.com/bmc/brizzled/blob/935ef1d0a4ba0015760aa1933977e4157a2ce8cc/_plugins/summary.rb).
The most important parts are:

{% highlight ruby %}
    module Jekyll

      class Summary

        def initialize(source_file, html_file)
          @summary_file = source_file
          @summary_html = html_file
        end

        def to_liquid
          # Return the location of the summary HTML file.
          File.exists?(@summary_file) ? get_html : ""
        end

        def has_summary?
          File.exists?(@summary_file)
        end

        def get_html
          make = false
          if not File.exists?(@summary_html)
            puts("#{@summary_html} does not exist. Making it.")
            make = true
          elsif (File.mtime(@summary_html) <=> File.mtime(@summary_file)) < 0
            puts("#{@summary_html} is older than #{@summary_file}. Remaking it.")
            make = true
          end

          if make
            html = Maruku.new(File.readlines(@summary_file).join("")).to_html
            FileUtils.mkdir_p(File.dirname(@summary_html))
            f = File.open(@summary_html, 'w')
            f.write(html)
            f.close
          else
            html = File.readlines(@summary_html).join("")
          end

          html
        end
      end
    end
{% endhighlight %}

The `get_html` method generates the summary HTML file, if it is out of date.
That method is called by `to_liquid`, which will *only* be called if the summary
is referenced within a Liquid template.

Another monkeypatch to `Page` ensures that the summary is set in the article:

{% highlight ruby %}
    module Jekyll
      class Page

        ...

        # Chained version of constructor, used to generate the location of
        # the "summary" file.
        alias orig_init initialize
        def initialize(site, base, dir, name)
            orig_init(site, base, dir, name)

            # Allow for a summary.md file that generates the article summary.
            @summary = Summary.new(File.join(@base, @dir, SUMMARY_FILE),
                                   File.join(@base, site.dest, @dir, 
                                             SUMMARY_HTML))
        end
      end
    end
{% endhighlight %}

With that small bit of code in place, a layout can force generation of a
summary merely be referencing it:

    {\% if article.has_summary \%}
    \{\{ article.summary \}\}
    {\% endif \%}
    
In addition, referring to the summary via `\{\{ article.summary \}\}`
substitutes its rendered content into the document.

# Conclusion

These relatively simple Jekyll hacks allow me to use Jekyll to handle this
blog, without requiring that I fork and hack the Jekyll code itself.

# Caveats

There may be more efficient, or more elegant, ways to solve some of these
issues. If you have any suggestions on how I can improve these hacks, feel
free to email me or leave a comment.

[Jekyll]: http://jekyllrb.com/
[plugins]: https://github.com/mojombo/jekyll/wiki/Plugins
[clapper.org web site]: http://www.clapper.org/
[company web site]: http://www.ardentex.com/
[crufty]: http://www.jargon.net/jargonfile/c/crufty.html
[monkeypatching]: http://stackoverflow.com/questions/394144/what-does-monkey-patching-exactly-mean-in-ruby
[Ruby]: http://www.ruby-lang.org/
[historical reasons]: ../77/
[post format]: https://github.com/mojombo/jekyll/wiki/Permalinks
[77]: ../77/
[App Engine template]: http://code.google.com/appengine/docs/python/gettingstarted/templates.html
[Liquid]: http://www.liquidmarkup.org/
[Markdown]: http://daringfireball.net/projects/markdown/
[top-level page template]: https://github.com/bmc/brizzled/blob/76f6bf8f2830b4c7c41a39d50ad12ca6aedd679b/_layouts/main.html
[YAML front matter]: https://github.com/mojombo/jekyll/wiki/YAML-Front-Matter
[Django]: http://www.djangoproject.com/
[Django template]: http://www.djangoproject.com/documentation/0.96/templates/
[Ruby delegates]: http://ruby-doc.org/docs/ProgrammingRuby/html/lib_patterns.html#S1
