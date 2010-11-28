template: article.html
title: Writing, Markdown and Pandoc
tags: writing, markdown, pandoc
date: 2010-11-26
toc: no

I've been doing a lot of my writing these days using [Markdown][] It's a
straightforward, simple markup language that converts cleanly to HTML;
there are various tools and APIs that do Markdown conversion.

I like Markdown for blogging; this blog's source is Markdown, for instance.
I write [user's guides][SQLShell Users Guide] using Markdown, as well.
Sites like [GitHub][] (where I host my code these days) support Markdown
natively. Like [TeX][] or [troff][], Markdown input is plain text, which
means I can use a real editor (such as [Emacs][]), rather than the less
powerful editors in word processing tools like Apple's [Pages][],
[OpenOffice.org Writer][], or [Microsoft Word][]. Also, because I'm editing
(mostly) plain text, I tend to focus on what I'm writing, rather than on
the typesetting.

Markdown is so lightweight that the markup doesn't get in the way of the
document contents, as well. You can generally read a Markdown source
document without tripping over a lot of extraneous markup. Also, since it's
so lightweight, the conversion tools tend to be fast and small; the
original Markdown script is written in Perl, as a series of regex
transformations. The Python markdown program is similarly small.

Not too long ago, I stumbled across a *really* useful tool called
[Pandoc][], written by [John MacFarlane][]. Pandoc converts from a variety
of markup formats to other markup formats. e.g.:

> If you need to convert files from one markup format into another,
> pandoc is your swiss-army knife. Need to generate a man page from a
> markdown file? No problem. LaTeX to Docbook? Sure. HTML to MediaWiki?
> Yes, that too. Pandoc can read markdown and (subsets of)
> reStructuredText, HTML, and LaTeX, and it can write plain text,
> markdown, reStructuredText, HTML, LaTeX, ConTeXt, PDF, RTF, DocBook
> XML, OpenDocument XML, ODT, GNU Texinfo, MediaWiki markup, groff man
> pages, EPUB ebooks, and S5 and Slidy HTML slide shows. PDF output (via
> LaTeX) is also supported with the included markdown2pdf wrapper script.

It's a cool utility, and I've begun to use it more and more. With Pandoc's
help, writing papers and other "real" documents in Markdown becomes even
easier. Using Markdown with Pandoc means I can generate HTML, PDF and ODT
(OpenOffice.org) files easily, using a simple [GNU Make][] Makefile:

    %.html: %.md style.css Makefile
        pandoc -c style.css -s -f markdown -t html --standalone -o $@ $<

    %.odt: %.md Makefile
        pandoc --standalone -f markdown -t odt -o $@ $<

    %.pdf: %.md %.odt
        markdown2pdf -f markdown -o $@ $<

    all: doc.html doc.odt doc.pdf

I'm pleasantly surprised by the results. There are pieces missing, of
course. I haven't figured out how to force page breaks yet, for instance.
But the advantage of editing in a very lightweight markup language, then
generating PDFs that are typeset through TeX, far outweighs any niggling
disadvantages.

As of version 1.6, Pandoc can generate [EPUB][] documents, as well. As the
Pandoc web site puts it, "EPUB books can be viewed on iPads, Nooks, and
other electronic book readers, including many smart phones. (They can also
be converted to Kindle books using [KindleGen][].)"

**Update:** [John MacFarlane][] writes, in an email:

> There's no general way to force page breaks, by the way.  If you just
> want page breaks in PDF (via latex), you can insert a raw latex
> command,
> 
>     \newpage
> 
> This should be ignored in HTML and ODT output, so it will only affect
> latex and PDF via latex.

Here's a list of Markdown-related tools I have found to be helpful:

* The [Pandoc][] document converter.
* [markdown-mode][], for [Emacs][].
* [TeX Live][], which allows Pandoc to generate LaTeX-typeset PDFs, among
  other things. (I use TeX Live on both Ubuntu Linux and Mac OS X.)
* [Lanyon][], the static site generator I use to generate this blog from
  Markdown source.
* John MacFarlane's [yst][] static site generator. (I will be switching
  this blog to [yst][], at some point.)
* Some APIs for parsing Markdown. (I use these APIs in some of my software
  development.)
    - [Markdown in Python][]
    - [Knockoff][], a [Scala][] Markdown parser
    - [MarkWrap][], my API for parsing Markdown, [Textile][] and other formats.
      Uses [Knockoff][] under the covers.

[yst]: https://github.com/jgm/yst
[Markdown]: http://daringfireball.net/projects/markdown/
[Lanyon]: http://bitbucket.org/arthurk/lanyon/wiki/Home
[Textile]: http://textile.thresholdstate.com/
[Knockoff]: http://tristanhunt.com/projects/knockoff/
[MarkWrap]: http://bmc.github.com/markwrap/
[Scala]: http://www.scala-lang.org/
[Markdown in Python]: http://www.freewisdom.org/projects/python-markdown/
[Pandoc]: http://johnmacfarlane.net/pandoc/
[John MacFarlane]: http://johnmacfarlane.net/
[SQLShell Users Guide]: http://bmc.github.com/sqlshell/users-guide.html
[GitHub]: http://www.github.com/
[TeX]: http://www.tug.org/texlive/
[troff]: http://www.troff.org/
[Emacs]: www.gnu.org/software/emacs/
[markdown-mode]: http://jblevins.org/projects/markdown-mode/
[Pages]: www.apple.com/iwork/pages/
[OpenOffice.org Writer]: http://wiki.services.openoffice.org/wiki/Writer
[Microsoft Word]: http://office.microsoft.com/en-us/word/
[GNU Make]: http://www.gnu.org/software/make/
[TeX Live]: http://www.tug.org/texlive/
[EPUB]: http://en.wikipedia.org/wiki/EPUB
[KindleGen]: http://www.amazon.com/gp/feature.html?ie=UTF8&docId=1000234621
