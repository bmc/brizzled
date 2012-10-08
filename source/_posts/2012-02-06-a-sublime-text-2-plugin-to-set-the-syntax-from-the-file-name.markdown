---
layout: post
title: "A Sublime Text 2 Plugin to Set the Syntax from the File Name"
date: 2012-02-06 14:35
comments: true
categories: [Sublime Text 2, syntax highlighting, editing, programming]
---

A few months ago, I switched from [GNU Emacs][], which I've used for more than
20 years, to [Sublime Text 2][]. After years of using Emacs, there _are_ a
few things I miss in Sublime Text 2. Fortunately, Sublime Text 2 has a rich
Python API, and it supports plugins; so, it's relatively easy to
[add features I miss][].

Like all decent modern programming editors, Sublime Text 2 supports syntax
highlighting. But, for various reasons, it can't always guess which syntax
applies to a file. For example, lately, I find myself editing a lot of [Sass][]
files. Sublime Text 2 always brings Sass files (i.e., files ending in `.scss`)
up as plain text files, with no syntax highlighting. I wanted a way to tell
Sublime that _all_ files ending in `.scss` should be assigned the "Ruby Sass"
syntax, by default.

In other words, I wanted the equivalent of this Emacs Lisp capability:

{% codeblock elisp lang:cl %}
(add-to-list 'auto-mode-alist '("\\.scss\\'" . sass-mode))
{% endcodeblock %}

<!-- more -->

There are various existing plugins that almost do what I want, kind of. For
example, Phillip Koebbe's [DetectSyntax][] plugin is, basically, an extensible
rules engine that can determine the syntax based on a file name, the contents
of the file, and many other conditions. It's even customizable via callbacks.
But, while DetectSyntax would surely do what I need, I _wanted_ something a
little simpler. (However, by all means, take a look at DetectSyntax. It's good
work.)

So I wrote one. Called [Sublime Text 2 Syntax from File Name][]
(ST2SyntaxFromFileName, for short), it simply maps a file name regular
expression into a syntax name.

The plugin is configured via the `filename_syntax_settings` value in the user
settings (accessible via the "Preferences &#8594; Settings - User" menu). That
value is an array of arrays, and each inner array element defines a mapping
from a regular expression to a syntax name. For instance, here's a portion of
my settings file:

{% codeblock Preferences.sublime-settings lang:javascript %}
{

  "filename_syntax_settings":
  [
    ["\\.scss", "Ruby Sass", "i"],
    ["\\.sass", "Ruby Sass", "i"]
  ],
  ...
}
{% endcodeblock %}

Those settings map files ending in `.scss` and `.sass` to the "Ruby Sass"
syntax value.

Each entry has two or three fields. The first two are mandatory. They are:

1. A regular expression pattern against which to match the filename. Note that backslashes must be double-escaped, because of the way the JSON parser works.
2. The syntax value to apply to matching files. The name must match the name of a `.tmLanguage` file somewhere underneath the Sublime Text 2 `Packages`irectory. The name is matched in a case-blind manner; thus, "Ruby" and "ruby" mean the same thing.
3. Optional flags for the regular expression parser. Currently, only "i", for case-blind comparison, is honored. Anything else is ignored.

The settings examined applied in order, and the first match wins.

While this plugin is far less powerful than the more general-purpose
[DetectSyntax][] plug Phillip Koebbe wrote, its simplicity suits my purposes
exactly. It's also a nice demonstration of how easily one can extend [Sublime
Text 2][].

[GNU Emacs]: http://www.gnu.org/s/emacs
[Sublime Text 2]: http://www.sublimetext.com/2
[add features I miss]: http://grundprinzip.github.com/sublemacspro/
[Sass]: http://sass-lang.com/
[DetectSyntax]: https://github.com/phillipkoebbe/DetectSyntax
[Sublime Text 2 Syntax from File Name]: http://software.clapper.org/ST2SyntaxFromFileName/
