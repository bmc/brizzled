---
layout: article
tags: scala, markdown, javascript, rhino, programming
title: Parsing Markdown in Scala
date: 2010-02-10 00:00:00
---

For documentation, simple markup is often best. For instance, I used to
write this blog in [reStructured Text][]; the blogging engine's Python
back-end converted the reStructured Text markup to HTML. (I now use
[Markdown][].)

When I started writing more [Scala][], I wanted to do something similar
with the documents (the user's guides, README files, etc.) that go with the
code I write. I looked for a reStructured Text parser in Scala or Java, but
I couldn't find one, and I didn't feel like writing one. I could probably
have used the existing [DocUtils][] package with [Jython][], but that
seemed like a lot of extra overhead, just to generate HTML from a simple
text markup file.

Eventually, I settled on [Markdown][]. Initially, I chose the Java-based
[MarkdownJ][] parser. Unfortunately, I ran into some problems, chief among
them that I kept getting exceptions when running MarkdownJ under Java 6. It
ran fine under Java 5, so this problem wasn't insurmountable. But MarkdownJ
also doesn't appear to be aggressively maintained these days. So, when I
began converting my Scala code to Scala 2.8, I also looked for another way
to convert my Markdown documents.

Googling around, I ran across Brian Carper's [Clojure and Markdown][] blog
entry, in which he describes using The Mozilla [Rhino][] Javascript engine
to run the Javascript [Showdown][] Markdown parser. One of Brian's reasons
for his approach was consistency: He wanted to be able to show users a
preview of parsed Markdown in the browser, but also have his Clojure-based
backend parse the same Markdown document. Using the same code (Showdown, in
his case) increased the chances that the HTML output would match.

This approach seemed reasonable to me, too, so I wrote a small function to
do the same thing in Scala. The Java 6 JDK I'm using on my Mac,
[SoyLatte][], does not ship with the [JSR 223][] (i.e., `javax.script`)
bindings for Rhino, so I elected to use the Rhino API directly.

Here's a simple Scala function that takes an iterator over lines of
Markdown (presumed *not* to have a trailing newline) and returns the HTML
markup produced by the Markdown processor.

{% highlight scala %}
private def markdown(markdownSource: Iterator[String]): String =
{
    import org.mozilla.javascript.{Context, Function}
    import java.io.InputStreamReader

    // Initialize the Javascript environment
    val ctx = Context.enter
    try
    {
        val scope = ctx.initStandardObjects

        // Open the Showdown script and evaluate it in the Javascript
        // context.

        val showdownURL = getClass.getClassLoader.getResource("showdown.js")
        val stream = new InputStreamReader(showdownURL.openStream)
        ctx.evaluateReader(scope, stream, "showdown", 1, null)

        // Instantiate a new Showdown converter.

        val converterCtor = ctx.evaluateString(scope, "Showdown.converter", "converter", 1, null)
                            .asInstanceOf[Function]
        val converter = converterCtor.construct(ctx, scope, null)

        // Get the function to call.

        val makeHTML = converter.get("makeHtml", converter).asInstanceOf[Function]

        // Load the markdown source into a string, and convert it to HTML.

        val markdownSourceString = markdownSource mkString "\n"
        val htmlBody = makeHTML.call(ctx, scope, converter,
                                     Array[Object][](markdownSourceString))
        htmlBody.toString
    }

    finally
    {
        Context.exit
    }
}
{% endhighlight %}

The generated HTML markup does not contain `html` or `body` tags, so we can
use a simple wrapper function, combined with Scala's inline XML
capabilities, to generate a full XHTML-compliant document. The following
function takes an iterator over lines of Markdown and optional
[Cascading Style Sheet][] content, and produces a complete HTML document.

{% highlight scala %}
def markdownToDocument(markdownSource: Iterator[String], css: String = null): String =
{
    import java.text.SimpleDateFormat
    import java.util.Date
    import scala.xml.parsing.XhtmlParser
    import scala.io.Source

    val Encoding = "ISO-8859-1"

    val markdownSourceLines = markdownSource.toList
    val htmlBody = markdown(markdownSourceLines.iterator)

    // Prepare the final HTML.

    val cssString = if (css != null) css else ""

    // Title is first line.
    val title = markdownSourceLines.head
    val sHTML = "&lt;body&gt;" + htmlBody + "&lt;/body&gt;"

    // Parse the HTML from the Markdown parser. We'll insert it into
    // the template.
    val body = XhtmlParser(Source.fromString(sHTML))
    val contentType = "text/html; charset=" + Encoding
    val htmlDocument = 
<html>
<head>
<title>{title}</title>
<style type="text/css">
{cssString}
</style>
<meta http-equiv="content-type" content={contentType}/>
</head>
<div id="body">
{body}
<hr/>
<i>Generated {new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date)}</i>
</div>
</html>

    htmlDocument.toString
}
{% endhighlight %}

There. [Markdown][] to HTML in [Scala][], by way of [Showdown][] and
[Rhino][]. It's kind of a roundabout way to get there, but it gets the job
done.

I'm currently using a variant of this technique in the [SBT][] build file
for one of my Scala projects, to convert various documents (including a
user's guide) from Markdown to HTML. I'm seriously considering putting a
more generic version, similar to the above, in my [Grizzled Scala][]
library.

**Update** (11 February, 2010): I put a version of this code in my
[Grizzled Scala][] library.

**Update** (3 March, 2010): Tristan Juricek's [Knockoff][] Markdown parser
looks very interesting. It's written in Scala, and it parses Markdown into
an internal object format.

**Update** (14 December, 2010): [MarkWrap][], a Scala wrapper API for
various lightweight markup APIs, replaces the Markdown parser that was in
my [Grizzled Scala][] library. [MarkWrap][] parses [Markdown][] and
[Textile][], and it can easily be extended to handle others.

[Textile]: http://textile.thresholdstate.com/
[MarkWrap]: http://software.clapper.org/markwrap/
[reStructured Text]: http://docutils.sourceforge.net/rst.html
[Scala]: http://www.scala-lang.org/
[DocUtils]: http://docutils.sourceforge.net/
[Jython]: http://www.jython.org/
[Markdown]: http://daringfireball.net/projects/markdown/
[MarkdownJ]: http://markdownj.sourceforge.net/
[Clojure and Markdown]: http://briancarper.net/blog/clojure-and-markdown-and-javascript-and-java-and
[Rhino]: http://www.mozilla.org/rhino/
[Showdown]: http://attacklab.net/showdown/
[SoyLatte]: http://landonf.bikemonkey.org/static/soylatte/
[JSR 223]: http://jcp.org/en/jsr/detail?id=223
[Object]: markdownSourceString
[Cascading Style Sheet]: http://en.wikipedia.org/wiki/Cascading_Style_Sheets
[Markdown]: http://daringfireball.net/projects/markdown/
[Scala]: http://www.scala-lang.org/
[Showdown]: http://attacklab.net/showdown/
[Rhino]: http://www.mozilla.org/rhino/
[SBT]: http://code.google.com/p/simple-build-tool/
[Grizzled Scala]: http://software.clapper.org/scala/grizzled-scala/
[Markdown parser]: http://github.com/bmc/grizzled-scala/raw/master/src/main/scala/grizzled/parsing/markdown.scala
[Grizzled Scala]: http://software.clapper.org/scala/grizzled-scala/
[Knockoff]: http://tristanhunt.com/projects/knockoff/
