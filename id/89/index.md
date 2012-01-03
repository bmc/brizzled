---
layout: article
tags: scala, repl, readline, programming
title: Readline support in Scala's REPL
date: 2009-04-29 00:00:00
---

Scala's command-line interpreter (its [REPL][]) is *highly* useful, but if
you're accustomed to [readline][], you'll find it lacking and frustrating.
Scala 2.8 is enhancing the REPL, but in the meantime, here's a handy trick.

Instead of typing

    $ scala

try this, instead:

    $ rlwrap scala -Xnojline

By disabling [JLine][] and invoking Scala via `rlwrap`, you get full
[readline][] capabilities in the Scala REPL.

On Windows, you can install the [Cygwin][] version of `rlwrap`; it seems to
work just fine in my tests.

Thanks to Tony Morris for [posting this tip][] to the [scala-user][]
mailing list.

[REPL]: http://en.wikipedia.org/wiki/REPL
[readline]: http://tiswww.case.edu/php/chet/readline/rltop.html
[JLine]: http://jline.sourceforge.net/
[readline]: http://tiswww.case.edu/php/chet/readline/rltop.html
[Cygwin]: http://www.cygwin.com/
[posting this tip]: http://www.nabble.com/Re:-rlwrap-with-scala-interpreter-p23291192.html
[scala-user]: http://www.nabble.com/Scala---User-f30217.html
