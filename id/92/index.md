---
layout: article
tags: scala, ant, rake, make, maven, ivy, gradle, SBT, programming
title: "SBT: A Scala-based Simple Build Tool"
date: 2009-07-19 00:00:00
---

Awhile ago, I embarked on an effort to build [yet another build tool][],
this one in [Scala][]. I shelved that effort, and I've switched to [SBT][],
instead.

I've had it with [Ant][], for all the reasons outlined in my
[previous build tool discussion][], and then some.

I looked at [Maven][] and [Ivy][], but, really, I am *so* over XML
configuration files. (Again, see previous rant.)

At one suggestion, I began to look at [Gradle][], a [Groovy][] build tool
with [Maven][], [Ivy][] and [Ant](http://ant.apache.org/) integration. Now
*this* was looking promising: A simple code-oriented configuration (no XML!
Yay!), with complete access to Ant tasks and full external dependency
management.

Before diving feet-first into Gradle, though, I decided to take a closer
look at [SBT][], a tool [Daniel Spiewak][] recommended. SBT bills itself as
"a simple build tool for Scala projects that aims to do the basics well."
SBT uses [Scala][], much the same way that Gradle uses Groovy; this is
appealing to me, since I'm doing most of my "elective programming" in Scala
these days. After digging a bit, I found that SBT has complete support for
external dependency management.

- Like Gradle, SBT has support for automatic external dependency
  management, using [Ivy][] under the covers.
- Also like Gradle, SBT integrates well with Maven repositories.
- It's completey trivial to support an external dependency on a jar file
  that isn't in Maven.
- If your project is laid out in a Maven directory structure (something SBT
  will create for you, if you want), SBT can generally figure out where
  everything is. If you don't need "extras" (such as external
  dependencies), you don't have to create a configuration file at all.
- If you don't like the Maven directory structure, or you want to change
  pieces of it (such as where the compiled code ends up), SBT lets you
  configure just those pieces easily.

In all, it's an impressive piece of software. I switched from using Ant to
using SBT to build my [Grizzled Scala Library][], and the resulting
configuration file was 15 lines long, including blank lines and comments.

I'm building a Scala-based replacement for my Python [sqlcmd][] tool
(because I've come to prefer JDBC to Python's DB API), and I switched that
project over, too. The Ant build file for that project is 250 lines of XML,
and it doesn't support external dependencies. The Maven POM file (if there
were one) would, of course, be smaller than that. But the configuration
file for SBT is trivial, and far more readable than a `pom.xml` file:

    import sbt._
    
    class SQLShellProject(info: ProjectInfo) extends DefaultProject(info)
    {
        override def compileOptions = Unchecked :: super.compileOptions.toList
    
        // External dependencies
    
        val scalaToolsRepo = "Scala-Tools Maven Repository" at 
            "http://scala-tools.org/repo-releases/org/scala-tools/testing/scalatest/0.9.5/"
    
        val scalatest = "org.scala-tools.testing" % "scalatest" % "0.9.5"
        val joptSimple = "net.sf.jopt-simple" % "jopt-simple" % "3.1"
        val jodaTime = "joda-time" % "joda-time" % "1.6"
    
        // Grizzled comes from local machine for now
        val grizzled = "grizzled-scala-library" % "grizzled-scala-library" % "0.1" from 
            "http://internal-repo/~bmc/code/grizzled-scala-library-0.1.jar"
    }

I'm sold.

[yet another build tool]: /id/87/
[Scala]: http://www.scala-lang.org/
[SBT]: http://code.google.com/p/simple-build-tool/
[Ant]: http://ant.apache.org/
[previous build tool discussion]: /id/87/
[Maven]: http://maven.apache.org/
[Ivy]: http://ant.apache.org/ivy/
[Gradle]: http://www.gradle.org/
[Groovy]: http://groovy.codehaus.org/
[Maven]: http://maven.apache.org/
[Ivy]: http://ant.apache.org/ivy/
[SBT]: http://code.google.com/p/simple-build-tool/
[Scala]: http://www.scala-lang.org/
[Ivy]: http://ant.apache.org/ivy/
[Grizzled Scala Library]: https://github.com/bmc/grizzled-scala/tree
[sqlcmd]: http://software.clapper.org/python/sqlcmd/
[Daniel Spiewak]: http://www.codecommit.com/blog/
