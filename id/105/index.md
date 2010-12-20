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
[crufty][], Jekyll hacks. The hacks are all accomplished via
[Jekyll plugins][] and [monkeypatching][], and they work with Jekyll 0.8.0.
(I haven't tested them with other versions.)

# Non-standard Blog Layout

For [historical reasons][], this blog uses a layout that doesn't match Jekyll's
blog-specific [post format][]. Each article has a unique numeric ID, and all
articles live within an `id` directory. So, the first problem to be solved is
to ensure that Jekyll finds and renders the blog's articles.

The solution is fairly simple. Underneath the top level of my blog
source, I created a `_plugins` directory; that's where Jekyll expects to
find plugin [Ruby][] code. Within that directory, I created a `site.rb`
file, with the following source.

{% highlight ruby %}
    module Jekyll

      # Extensions to the Jekyll Page class.

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
* It augments the stock Jekyll `site_payload` method to add the list of
  blog posts (and some other information) to the payload, thus making them
  available to the [Liquid][] templates.

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
places--including within my `Site.blog_posts` method.

The code also chains the `to_liquid` method, to augment the hash table of
data available to the Liquid template, when a page is being rendered. The
custom version of `to_liquid` adds the following values:

`date`:
:  Because my blog articles don't have a date in the file name, I have to be
   able to specify the publication date somewhere. I do so via the `date`
   variable in the YAML front-matter. The code ensures that the parsed date
   is available to the Liquid template.

`max_top`:
:  `max_top` controls the number of articles shown on the summary (top) page
   of the blog. The code uses the the value of `max_top` from the page's
   YAML front matter is used, if it's present. (Realistically, this value
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
contains [App Engine template markup][] that confuses The [Liquid][] template
engine Jekyll uses. The occurrence of a block of code like this:

    {\% block main \%}
    {\% endblock \%}
    
can cause Liquid to throw an exception about a bad tag ("block"). Similarly,
something like this:

    \{\{ article.path \}\}

can result in an empty line, because Liquid will attempt to substitute the
value of `article.path`, only to find it *has* no value.

I needed to add a means of escaping those tags, so that Liquid would ignore
them. The solution is fairly simple. Underneath the top level of my blog
source, I created a `_plugins` directory; that's where Jekyll expects to
find plugin [Ruby][] code. Within that directory, I created a `page.rb`
file with the following source.

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
with my own version of that method, which:

* first invokes the actual Jekyll `Page.render()` method, then
* replaces escaped Liquid tags with their actual tags.

This small hack allows me to represent Liquid (or Django) template markup
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
tags in an article's YAML front-matter. For instance:

    ---
    layout: article
    title: Some Jekyll Hacks
    tags: jekyll, ruby, blogging, liquid
    ---

## Goal 2: Allow the layout for a page to be able to see the page's tags

To make the tags available to the page, I first modified my `_plugins/page.rb`
file, to monkeypath a `tags` method into the `Page` class:

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

## Goal #4: Generate a page for each tag

A Jekyll generator plugin (see the [Jekyll plugins][] page) solved this
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


# Printer-friendly Pages

I believe blogs should provide printer-friendly formats, and this blog is no
exception. However, generating a printer-friendly version of each article isn't
something Jekyll can do, out of the box. Stock Jekyll generates a single HTML
file from the combination of a layout (template) and a markup article. Generating
two HTML files from the same input article requires a little code.


[Jekyll]: http://jekyllrb.com/
[Jekyll plugins]: https://github.com/mojombo/jekyll/wiki/Plugins
[clapper.org web site]: http://www.clapper.org/
[company web site]: http://www.ardentex.com/
[crufty]: http://www.jargon.net/jargonfile/c/crufty.html
[monkeypatching]: http://stackoverflow.com/questions/394144/what-does-monkey-patching-exactly-mean-in-ruby
[Ruby]: http://www.ruby-lang.org/
[historical reasons]: ../77/
[post format]: https://github.com/mojombo/jekyll/wiki/Permalinks
[77]: ../77/
[App Engine template markup]: http://code.google.com/appengine/docs/python/gettingstarted/templates.html
[Liquid]: http://www.liquidmarkup.org/
[Markdown]: http://daringfireball.net/projects/markdown/
