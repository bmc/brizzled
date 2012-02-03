---
layout: post
comments: false
title: "Loving Scala 2.8"
date: 2010-02-05 00:00
categories: [scala, programming]
---

The [Scala 2.8.0 Beta 1 prerelease][] was released on January 27, 2010. I
have finally begun converting my Scala code to 2.8. During the first pass
of the conversion, I changed my code to get replace calls that are now
deprecated or no longer supported. The second pass, however, has been more
interesting.

Scala 2.8 adds [many new features][]. So far, I've only managed to play
with a few of them, but those few features I've tried really make a
difference. For instance:

- Named and default arguments have allowed me to simplify some of my
  objects and classes, sometimes dramatically. Alternate constructors and
  overloaded methods often just go away, to be replaced by a single method
  with default parameter values. I really like this feature in other
  languages, like [Python][], and I'm thrilled that Scala finally has it.

- The new `@tailrec` annotation is fabulous. There are places in my code
  where I assumed [tail call optimization][] was happening, but I hadn't
  bothered to verify it by looking at the byte code. Using `@tailrec`, I'm
  quickly finding the ones where my assumptions were wrong, without having
  to disassemble the class files myself. This one simple feature is proving
  to be an incredible time-saver.

- The revamped Scala REPL is a joy to work with. The addition of tab
  completion alone has proved to be incredibly useful.

As I dig further into Scala 2.8, I fully expect to find other wonders. I am
looking forward to digging more deeply into the redesigned collection
libraries.

[Scala 2.8.0 Beta 1 prerelease]: http://www.scala-lang.org/downloads
[many new features]: http://www.scala-lang.org/node/1564
[Python]: http://www.python.org/
[tail call optimization]: http://c2.com/cgi/wiki?TailCallOptimization
