---
layout: post
title: "Generating a QR Code in Scala"
date: 2012-10-19 21:00
comments: true
categories: [scala, qr, qrcode, sbt]
---

I recently discovered that I needed to generate [QR codes][] in Scala,
and it turns out to be quite simple, with the help of the [QRGen][] Java
library, by [Ken Gullaxen][].

In this brief article, I demonstrate how to create a simple [SBT][]
project to pull in the appropriate dependencies, as well as how to call
the QRGen library from Scala.

<!-- more -->

QRGen is a front-end to the [ZXing][] library provided by Zebra Crossing. QRGen
makes generating QR codes trivial.

## Step 1: Create an SBT project

I use Nathan Hamblen's [giter8][] tool, along with Typesafe's [scala-sbt.g8][]
template:

{% codeblock lang:bash %}
{% raw %}
$ g8 typesafehub/scala-sbt
Scala Project Using sbt 

organization [org.example]: org.clapper
name [Scala Project]: QRTest
scala_version [2.9.2]: 
version [0.1-SNAPSHOT]: 

Template applied in ./qrtest
{% endraw %}
{% endcodeblock %}

_giter8_ creates a stub SBT project, including an initial
[SBT full build definition][] file. In this case, since I named the
project _QRTest_, it created the project tree in subdirectory `qrtest`, and
the build definition in `qrtest/project/QrtestBuild.scala`.

The initial contents of `QrtestBuild.scala` are:

{% codeblock Inital QrtestBuild.scala lang:scala %}
{% raw %}
import sbt._
import sbt.Keys._

object QrtestBuild extends Build {

  lazy val qrtest = Project(
    id = "qrtest",
    base = file("."),
    settings = Project.defaultSettings ++ Seq(
      name := "QRTest",
      organization := "org.clapper",
      version := "0.1-SNAPSHOT",
      scalaVersion := "2.9.2"
  )
}
{% endraw %}
{% endcodeblock %}

## Step 2: Add the library dependencies

Next, modify `QrtestBuild.scala` to depend on QRGen. To do so, simply add the
QRGen Maven repository and the artifact, as shown in lines 14 through 16,
below. Note that I'm also adding a dependency on my [Grizzled Scala][] library,
because it has a useful file copy routine.

{% codeblock Specifying QRGen dependency in QrtestBuild.scala lang:scala %}
{% raw %}
import sbt._
import sbt.Keys._

object QrtestBuild extends Build {

  lazy val qrtest = Project(
    id = "qrtest",
    base = file("."),
    settings = Project.defaultSettings ++ Seq(
      name := "QRTest",
      organization := "org.clapper",
      version := "0.1-SNAPSHOT",
      scalaVersion := "2.9.2",
      resolvers += "QRGen" at "http://kenglxn.github.com/QRGen/repository",
      libraryDependencies += "net.glxn" % "qrgen" % "1.1",
      libraryDependencies += "org.clapper" %% "grizzled-scala" % "1.0.13"

    )
  )
}
{% endraw %}
{% endcodeblock %}

## Step 3: Generate a QR code interactively

At this point, the SBT project is ready. There's no code in it, other than
the build file. However, we can use the SBT console to test generating
a QR code. First, fire up SBT:

{% codeblock %}
{% raw %}
$ sbt
[info] Loading global plugins from /home/bmc/.sbt/plugins/project
[info] Loading global plugins from /home/bmc/.sbt/plugins
[info] Loading project definition from /home/bmc/tmp/qrtest/project
[info] Updating {file:/home/bmc/tmp/qrtest/project/}default-7a3da4...
[info] Resolving org.scala-sbt#root;0.0 ...
...
[info] Compiling 1 Scala source to /home/bmc/tmp/qrtest/project/target/scala-2.9.2/sbt-0.12/classes...
[info] Set current project to QRTest (in build file:/home/bmc/tmp/qrtest/)
>
{% endraw %}
{% endcodeblock %}

Then, bring up the Scala console:

{% codeblock %}
> console
[info] Updating {file:/home/bmc/tmp/qrtest/}qrtest...
[info] Resolving org.scala-lang#scala-library;2.9.2 ...
[info] Resolving net.glxn#qrgen;1.1 ...
[info] Resolving com.google.zxing#core;2.0 ...
[info] Resolving com.google.zxing#javase;2.0 ...
[info] Resolving jline#jline;2.6 ...
[info] Done updating.
[info] Compiling 1 Scala source to /home/bmc/tmp/qrtest/target/scala-2.9.2/classes...
[info] Starting scala interpreter...
[info] 
Welcome to Scala version 2.9.2 (Java HotSpot(TM) 64-Bit Server VM, Java 1.6.0_26).
Type in expressions to have them evaluated.
Type :help for more information.

scala> 
{% endcodeblock %}

And, now, we can fiddle:

{% codeblock %}
{% raw %}
scala> import net.glxn.qrgen._
import net.glxn.qrgen._

scala> import grizzled.file.GrizzledFile._
import grizzled.file.GrizzledFile._

scala> val f = QRCode.from("http://brizzled.clapper.org/").file()
f: java.io.File = /tmp/QRCode5131788435518615347.png

scala> f.copyTo("/tmp/qr.png")
res0: java.io.File = /tmp/qr.png
{% endraw %}
{% endcodeblock %}

That's it: Four lines of code, including two `import` statements, to generate a
QR code and save it to a file. Note that QRGen's `file()` call saves the image
to a temporary file that is deleted with the Java VM exits. The `copyTo()`
call just saves it someplace more permanent.

Here's the result:

{% img /images/2012-10-19-generating-a-qrcode-in-scala/qr.png %}

## For more information

QRGen has many more features. Check out [the QRGen web page][QRGen].

If you want to get into the detailed nitty gritty, you can bypass QRGen
and go directly to the [ZXing][] API. But QRGen is so easy, why bother?

[Ken Gullaxen]: https://github.com/kenglxn
[QR codes]: http://en.wikipedia.org/wiki/QR_code
[ZXing]: http://code.google.com/p/zxing/
[QRGen]: http://kenglxn.github.com/QRGen/
[SBT]: http://scala-sbt.org/
[giter8]: https://github.com/n8han/giter8
[scala-sbt.g8]: https://github.com/typesafehub/scala-sbt.g8
[SBT full build definition]: http://www.scala-sbt.org/release/docs/Getting-Started/Full-Def.html