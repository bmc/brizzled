---
layout: post
title: "Generating a Table of Contents in Octopress"
date: 2012-02-04 19:28
comments: true
categories: [blogging, jekyll, octopress, javascript, css, programming]
toc: true
---

# Introduction

I recently converted this blog from raw [Jekyll][] to [Octopress][]. Octopress
uses Jekyll underneath, but it layers a large number of blog-friendly
capabilities on top.

One of the features I need to rebuild for Octopress was the ability to generate
a table of contents (like the one for this article), for some of the larger
articles.

This article describes how I accomplished that goal.

<!-- more -->

# Requirements

I wanted the generated table of contents to meet the following requirements:

* It should be easy to style. In particular, I want it to look different
  on the screen and printer-friendly versions of a page.
* It should be implemented as an HTML unnumbered list (i.e., a &lt;ul&gt;),
  for maximum styling flexibility.
* It should be automatic: That is, the code should automatically generate the
  table of contents from the headings (&lt;H1&gt;, &lt;H2&gt;, etc.) in the
  document.
* It should be optional. That is, I should be able to enable or disable it
  on a per-article basis.
* If I accidentally enable it on an article that has no heading elements,
  I don't want to see an empty table of contents in the document.

# Server-side or client-side?

Ideally, since Octopress generates static HTML, I'd like to have a 
[Liquid][] tag to embed in the appropriate place inside one of my templates.
Something like this would be ideal:

{% codeblock What I would like %}
{% raw %}
{% table-of-contents %}
{% endraw %}
{% endcodeblock %}

Unfortunately, that's a bit of a pain to implement. Instead, I elected to
use Doug Neiner's [jQuery table of contents plugin][] to generate the table
of contents in Javascript, when the browser loads the page.

# Implementation Steps

## jQuery

You can either download jQuery and install it directly in the source tree for
your Octopress blog, or you can use it from one of the public CDNs, like
Google. See <http://docs.jquery.com/Downloading_jQuery> for a list of CDNs.

If you elect to download it and install it locally, copy the appropriate
file (e.g., `jquery-1.7.1.min.js`) to your blog's `source/javascripts/`directory.

Next, modify `source/_includes/custom/head.html` to include a `<script>`
tag for jQuery. For a local install, use this line:

{% codeblock Add this to source/_includes/custom/head.html lang:html %}
{% raw %}
<script src="{{ root_url }}/javascripts/jquery-1.7.1.min.js" type="text/javascript"></script>
{% endraw %}
{% endcodeblock %}

To use the version of jQuery hosted on Google, use this line:

{% codeblock jQuery on the Google CDN lang:html %}
{% raw %}
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js" type="text/javascript"></script>
{% endraw %}
{% endcodeblock %}

You also have to use `jQuery.noConflict()`, to prevent conflicts between
jQuery's use of the '$' alias and the '$' used in `ender.js`, which is
automatically included by Octopress. So, regardless of where you source
jQuery, add this code, right after the `<script>` tag that pulls jQuery in:

{% codeblock jQuery on the Google CDN lang:html %}
{% raw %}
<script type="text/javascript">
  // Revert jQuery's '$' alias, to avoid clashes with ender.js. NOTE: Use
  // jQuery(...), instead of $(...) from here on.
  jQuery.noConflict();
</script>
{% endraw %}
{% endcodeblock %}

## Generating the Table of Contents

To generate the table of contents, you'll need to add some Javascript that
fires when each page loads. There are two conditions, however:

1. The Javascript should _only_ run if the article is marked as requiring
   a table of contents.
2. The Javascript should _not_ run if Octopress is generating the index
   page, which can have multiple blog articles on it.

### The Javascript

First, let's take a look at the Javascript itself. I chose to put the bulk
of the logic into a separate function, in a separate Javascript file called
`generate-toc.js`. (You can see the source for that file in my
[blog's GitHub repo][generate-toc]. I've also reproduced it, below.

{% codeblock generate-toc.js %}
function generateTOC(insertBefore, heading) {
  var container = jQuery("<div id='tocBlock'></div>");
  var div = jQuery("<ul id='toc'></ul>");
  var content = $(insertBefore).first();

  if (heading != undefined && heading != null) {
    container.append('<span class="tocHeading">' + heading + '</span>');
  }

  div.tableOfContents(content);
  container.append(div);
  container.insertBefore(insertBefore);
}
{% endcodeblock %}

The `insertBefore` parameter is a jQuery string selector for the element to
search for the table of content headings. The optional `heading` parameter
specifies the heading to preced the table of contents.

Copy `generate-toc.js` to `source/javascripts` and put the following line in
`source/_includes/custom/head.html`:

{% codeblock Add this to source/_includes/custom/head.html lang:html %}
{% raw %}
<script src="{{ root_url }}/javascripts/generate-toc.js" type="text/javascript"></script>
{% endraw %}
{% endcodeblock %}

### Hooking the Javascript In

The next step is to call `generateTOC()` at the right time. The following hunk
of code goes at the bottom of `source/_includes/custom/after_footer.html`:

{% codeblock source/_includes/custom/after_article.html %}
{% raw %}
{% if index %}
  {% comment %}
  No table of contents on the index page.
  {% endcomment %}

{% elsif page.toc == true %}
  <script type="text/javascript">
  jQuery(document).ready(function() {
    // Put a TOC right before the entry content.
    generateTOC('.entry-content', 'Table of Contents');
  });
  </script>
{% endif %}
{% endraw %}
{% endcodeblock %}

**Things to note:**

Octopress sets the `index` variable if it's generating the index page; if that
variable is set, we don't want to generate a table of contents.

Note, too, that the code only generates the table of contents if the `page.toc`
variable is set to "true". `page.toc` will be true only if the following line
is in the [YAML front matter][] of an article. For example:

{% codeblock Article Front Matter %}
---
layout: post
title: "Generating a Table of Contents in Octopress"
date: 2012-02-04 16:28
comments: true
categories: [blogging, jekyll, octopress]
toc: true
---
{% endcodeblock %}

If the `toc` line is missing or set to something other than "true", the 
table of contents is skipped.

The Javascript fires when the document has finished loading, using jQuery's
`jQuery(document).ready()` hook. Octopress assigns the `.entry-hook` class to
the `<div>` element that contains the generated article content. Passing that
selector string to `generateTOC()` ensures that we don't pick up any heading
elements that happen to live somewhere else in the HTML. The second parameter,
the string "Table of Contents", puts a heading above the generated table of
contents.

## Styling

`generateTOC()` puts the table of contents inside a `<ul>` element, which tells
the jQuery Table of Contents plugin to generate a nested list. I chose to
style that list one way for the screen and another way for the printed page.
(You can see the difference by printing this article.)

### Screen Styling

Octopress already has a `sass/screen.scss` file, but I want to keep my local
screen-specific stylings in a custom file. So, I created
`sass/custom/_screen.scss` for my screen-specific rules, and added this line to
`sass/screen.scss`:

{% codeblock sass/screen.scss lang:sass %}
{% raw %}
@import "custom/screen";
{% endraw %}
{% endcodeblock %}

Then, in `sass/custom/_screen.scss`, I put the following rules:

{% codeblock sass/custom/_screen.scss lang:sass %}
{% raw %}
$toc-bg: #dfdfdf;

$toc-incr: 5px;

div#tocBlock {
    @include drop-shadow-right-bottom(5px, #999);
    @include rounded-border(10px);
    float: right;
    font-size: 10pt;
    width: 300px;
    padding-left: 20px;
    padding-right: 10px;
    padding-top: 10px;
    padding-bottom: 0px;

    background: $toc-bg;
    border: solid 1px #999999;
    margin: 0 0 10px 15px;

    .tocHeading {
        font-weight: bold;
        font-size: 125%;
    }

    #toc {
        background: $toc-bg;
        ul {
            list-style: disc;
            li {
                margin-left: $toc-incr !important;
                padding: 0 !important;
            }
        }
    }
}
{% endraw %}
{% endcodeblock %}

That styling:

* causes the table of contents to float to the right of the text
* gives it a light gray background
* ensures that the nested lists are without too much indentation
* forces all lists to use disc bullets, regardless of nesting level.

### Printer-friendly Styling

Octopress does not (yet) ship with a `sass/print.scss` file, so I created one.
For consistency with the screen styling (and the rest of the SASS files), that
file just includes a custom `sass/custom/_print.scss` file. Here's
`sass/print.scss`:

{% codeblock sass/screen.scss lang:sass %}
{% raw %}
@import "custom/print";
{% endraw %}
{% endcodeblock %}

Then, in `sass/custom/_screen.scss`, I put the following rules:

{% codeblock sass/custom/_print.scss lang:sass %}
{% raw %}
$toc-incr: 1em;

div#tocBlock {
    font-size: 10pt;
    padding-left: 20px;
    padding-right: 10px;
    padding-top: 10px;
    padding-bottom: 0px;

    background: white !important;
    border: solid 1px #999999;
    margin: 0 0 10px 15px;

    .tocHeading {
        font-weight: bold;
        font-size: 125%;
    }

    #toc {
        background: white !important;
        ul {
            list-style: disc;
            li {
                margin-left: $toc-incr !important;
                padding: 0 !important;
            }
        }
    }
}
{% endraw %}
{% endcodeblock %}

# Voil&agrave;!

The result of all that work is a table of contents that looks like this:

{% imgpopup /images/2012-02-04-generating-a-table-of-contents-in-octopress/screenshot1.png 50% Screenshot with Table of Contents %}

# References

* [`jQuery.noConflict()`](http://api.jquery.com/jQuery.noConflict/)
* [jQuery Table of Contents Plugin](http://fuelyourcoding.com/table-of-contents-jquery-plugin/)
* [The source for the generateTOC() function][generate-toc]

[Jekyll]: http://jekyllrb.com/
[Octopress]: http://octopress.org/
[Liquid]: https://github.com/Shopify/liquid
[jQuery table of contents plugin]: http://fuelyourcoding.com/scripts/toc/
[YAML front matter]: https://github.com/mojombo/jekyll/wiki/yaml-front-matter
[generate-toc]: https://github.com/bmc/brizzled/blob/master/source/javascripts/generate-toc.js