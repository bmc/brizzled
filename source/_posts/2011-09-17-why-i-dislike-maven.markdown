---
layout: post
comments: true
title: "Why I dislike Maven"
date: 2011-09-17 00:00
categories: [maven, java, buildr, xml, programming]
toc: true
---

# Introduction

A few nights ago, I converted
[one of my long-running, open source, Java libraries][javautil] from its
horrid, old-style [Ant][] build to [Maven][], largely because of several
advantages Maven provides:

* It manages third-party dependencies cleanly and simply.
* It allows me to publish my library in a Maven repository, so that others
  who use Maven can easily depend on my library.
* It's the defacto standard Java build environment.

Those are powerful advantages. The dependency management, alone, is an
incredible time saver.

Nevertheless, one day after making the Maven switch, I ditched Maven for
Apache [Buildr][].

<!-- more -->

# Why I dislike Maven

The title of this article is *Why I dislike Maven*, but that title is worth
clarifying. There are aspects of Maven that are terrific. Its dependency
management is excellent, and the Maven-imposed source code layout is clean
and well organized. Because of that standard source layout, many Java
projects have Maven POM files that are nothing more than a listing of
dependencies; Maven figures out the rest automatically.

But Maven suffers from a few flaws that drive me nuts.

## XML configuration sucks

XML is a decent enough syntax for data, but XML is a crappy configuration
language. For one thing, XML is verbose. Take a look at this Maven XML
fragment:

    <project xmlns="http://maven.apache.org/POM/4.0.0"
             xmlns:xsi="http://www.w3. org/2001/XMLSchema-instance"
             xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">

      <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
      </properties>
      ...

You have to wade through a lot of extraneous characters to get to the meat
of that configuration item, which is: **the build source encoding is
UTF-8**.

Imagine the same thing in a more typical configuration syntax:

    project.build.sourceEncoding = UTF-8

[YAML][] would also be a better choice than XML:

    project:
      properties:
        build.sourceEncoding: UTF-8

Those latter two formats are more readable, with less visual noise, than
the Maven XML version.

A fully-loaded Maven configuration file--even a simple one­-can look like a
[big, gray blob][javautil-pom], with all that XML markup getting in the way
of the actual semantics of the build file.

Maven is also *declarative*, but not *procedural*. If I want to augment
Maven's logic--say, introduce a new goal--I have to do it through a custom
Maven plugin; I can't just stuff some special procedural logic into my POM.
If I have to copy some extra files, that's a rather high bar to clear.

I'm not the only person who thinks XML sucks as a configuration language.
A full decade ago, [Terence Parr][], author of [ANTLR][] and [StringTemplate][],
wrote an article entitled [*Humans should not have to grok XML*][parr-xml].
Among the many good points he made, he wrote:

> I hope to convince you that humans should not have to write and grok XML.
> Besides the many existing standard special-purpose languages that provide
> superior interfaces, XML is about as far away from natural human language
> as you can get.
>
> My argument is simple: Humans have an innate ability to apply structure
> to a stream of characters (sentences), therefore, adding markup symbols
> can only make it harder for us to read and more laborious to type. The
> problem is that most programmers have very little experience designing
> and parsing computer languages. Rather than spending the time to design
> and parse a human-friendly language, programmers are using the fastest
> path to providing a specification language and implementation: "Oh, use
> XML. Done." And that's OK, but I want programmers to recognize that they
> are providing an inferior interface when they take that easy route.

Parr outlines, very clearly, why XML is an inferior language for
*human-to-computer* interaction.

[Polyglot Maven][] has promise, since it provides a way to express Maven
POMs in Groovy, Scala, Clojure and JRuby, among others. I'll admit that
I've only played with Polyglot Maven a little bit. However, Polyglot Maven
is really just Maven, with language-specific syntaxes replacing the XML
version of the POM. As far as I can tell, from reading and experimenting
with Polyglot Maven, I *still* can't escape Maven's declarative nature very
easily. I can't, for instance, just add some new inline Scala code to
accomplish some project-specific task.

Clearly, what I want is something with Maven's dependency-handling power,
but with an easy way to escape to a real programming language, in case I
have to do some local, heavy lifting.

## Yeah, but what's my alternative?

There *are* alternatives to Maven, alternatives that still retain the power
of Maven's terrific dependency management and publishing capabilities,
without shoving all that hard-to-read XML in your face.

In the [Scala][] world, for instance, the defacto standard build tool is
[SBT][]. Using [Ivy][] under the covers, SBT provides powerful dependency
management, and it understands how to use and publish to Maven
repositories. Most important, in all the Scala projects I've written (and
there are more than a few in my [GitHub account][]), I've *never* had to
write a single line of Ivy or Maven XML. Not one. In SBT, specifying a
dependency uses a simple DSL that's far easier to read than Maven's XML:

    libraryDependencies <<= "org.clapper" % "javautil" % "3.0.1"

All the artifact information is there, without much extraneous markup
getting in the way.

## So, why Buildr?

While I use [SBT][] heavily, in my Scala work, I wanted to keep things even
simpler for anyone who might want to build my Java library. [SBT][] can be
complicated, for the uninitiated. [Buildr][] is a little simpler. Buildr
riffs on [Rake][], the standard Ruby build tool. [Rake][] does a *terrific*
job of hitting a very sweet spot. It provides a simple, easy-to-read
internal [DSL][] for specifying tasks and task relationships, but it allows
you to escape to the full power of the Ruby programming language when you
need to accomplish some out of the ordinary task (something that is
annoying, and often difficult, with Maven).

As [Martin Fowler wrote][fowler-rake]:

> The fact that *rake* is an internal DSL for a general purpose language is
> a very important difference between it and \[tools like *make* and Ant\].
> It essentially allows me to use the full power of Ruby any time I need
> it, at the cost of having to do a few odd looking things to ensure the
> rake scripts are valid Ruby. Since Ruby is a unobtrusive language,
> there's not much in the way of syntactic oddities. Furthermore since Ruby
> is a full blown language, I don't need to drop out of the DSL to do
> interesting things--which has been a regular frustration using *make* and
> Ant. Indeed I've come to view that a build language is really ideally
> suited to an internal DSL because you do need that full language power
> just often enough to make it worthwhile--and you don't get many
> non-programmers writing build scripts.

[Buildr][] is very similar to [Rake][], but it adds Maven-style dependency
management. Compare [my library's Maven POM][javautil-pom] with the
corresponding [Buildr][] configuration:

{% codeblock lang:ruby %}
# Dependencies.
JAVAX            = 'javax.activation:activation:jar:1.1-rev-1'
JAVAMAIL         = 'javax.mail:mail:jar:1.4.4'
ASM              = 'asm:asm:jar:3.3.1'
ASM_COMMONS      = 'asm:asm-commons:jar:3.3.1'
COMMONS_LOGGING  = transitive('commons-logging:commons-logging:jar:1.1.1')

LOG4J            = 'log4j:log4j:jar:1.2.16'

# Where we publish
UPLOAD_REPO      = 'sftp://maven.clapper.org/var/www/maven.clapper.org/html'

# The project definition itself.
define 'javautil' do
  project.version = '3.0.1'
  project.group   = 'org.clapper'

  package :jar

  compile.using :target => '1.5', :lint => 'all', :deprecation => true
  compile.with JAVAX, JAVAMAIL, ASM, ASM_COMMONS, COMMONS_LOGGING

  test.using :environment => {}, :fork => true
  test.with LOG4J

  repositories.remote << 'http://www.ibiblio.org/maven2/'
  repositories.release_to[:url] = UPLOAD_REPO
  repositories.release_to[:username] = 'bmc'
end
{% endcodeblock %}

Not only is the Buildr file simply shorter than the Maven POM, it's easier
to read and easier to customize. And, if I need to add a custom task, I can
do so with ease:

{% codeblock lang:ruby %}
project 'javautil' do
  ...
  # My custom thing depends on the compile succeeding.
  task :custom => :compile do
    # my custom logic, in Ruby, goes here
  end
end
{% endcodeblock %}

# Conclusion

The power and usefulness of Maven's dependency management cannot possibly
be overstated. But, in 2011, I can't see why I should use such a crappy
configuration file format, especially when there are much better
alternatives.

[GitHub account]: https://github.com/bmc/
[javautil]: http://software.clapper.org/javautil/
[Maven]: http://maven.apache.org/
[Ant]: http://ant.apache.org/
[Buildr]: http://buildr.apache.org/
[Rake]: http://rake.rubyforge.org/
[Ruby]: http://www.ruby-lang.org/
[SBT]: https://github.com/harrah/xsbt/wiki
[Ivy]: http://ant.apache.org/ivy/
[Scala]: http://www.scala-lang.org/
[YAML]: http://yaml.org/
[javautil-pom]: https://raw.github.com/bmc/javautil/1176821ba7c49a062f23f9b6eca720adb6782b52/pom.xml
[parr-xml]: http://www.ibm.com/developerworks/xml/library/x-sbxml/index.html
[Terence Parr]: http://www.cs.usfca.edu/~parrt/
[ANTLR]: http://www.antlr.org/
[StringTemplate]: http://stringtemplate.org/
[fowler-rake]: http://martinfowler.com/articles/rake.html
[DSL]: http://en.wikipedia.org/wiki/Domain-specific_language
[Polyglot Maven]: https://github.com/sonatype/polyglot-maven
