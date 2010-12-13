---
title: SBT and Your Own Maven Repository
tags: scala, sbt, maven
date: 2010-05-07
layout: article
toc: yes
---

# Introduction

I have been doing my personal development primarily in
[Scala][] lately, and I use the excellent 
[SBT][] (Simple Build
Tool) program to build my code.

To make the my libraries accessible to others, I could simply place
the jar file somewhere, such as the "download" area of the
project's [GitHub][] repository. This works
fine, as long as the jar has no dependencies. However, if my jar
depends on other libraries, anyone using my code has to chase down
and install those dependencies. A better solution is to create and
deploy a [Maven][] file, since the POM file
will capture those dependencies.

As it happens, SBT has excellent support for Maven. It will
generate a POM automatically, and it will publish to a Maven
repository. In most cases, you never have to write a single line of
Maven XML; SBT handles all that for you.

Since I already have a public server, I found it easier to create
and manage my own Maven repository, rather than try to get
authorization to publish to a well-known one.

This brief article describes one way to get SBT to publish to a
personal Maven repository.

# Assumptions

I make the following simplifying assumptions in this article. (They
happen to mirror my own situation.)

-   Only one user will be publishing to the repository.
-   That user can log into the remote system that hosts the
    repository.
-   The remote directory containing the repository's contents can
    be written by that user (i.e., you have sufficient permissions to
    set that up).

# Create your Maven repository

The first step is to create your Maven repository. I currently use
the [nginx][] web server running on a Linux
server, though these instructions will work with most web servers.
(These instructions, however, are specific to Unix-like systems.)

Create a virtual host for your Maven repository. (The instructions
for creating a virtual host for your particular web server are
beyond the scope of this article. Consult your web server's
documentation.)

As part of creating the virtual host, you'll have to create a
directory for the host's content. You don't have to create any
subdirectories; SBT's Maven publishing facilities will do that for
you. However, you *will* have to make the directory writable by
whatever user will publish content to the repository. My approach
was to make the directory owned by me, since I obviously have SSH
login privileges on my own server. (**Don't** publish as "root".
You're only asking for trouble, if you do that.)

In my case, with *nginx*, I did something like this:

    $ sudo mkdir -p /var/www/maven.example.org/html
    $ sudo chown bmc /var/www/maven.example.org/html

# Update your SBT project to publish to your repository

Now, you have to update your SBT project to publish to your
repository. If you don't already have a build file, you'll have to
create one, in your project's \`project/build\` subdirectory. See
the
[SBT Build Configuration][]
documentation for details.

Once you have your build file (a Scala source file), you merely
need to add two lines to start publishing right away:

    override def managedStyle = ManagedStyle.Maven
    lazy val publishTo = Resolver.sftp("My Maven Repo", "maven.example.org", "/var/www/maven/html")

\`publishTo\` defines your Maven repository. The first parameter is
an arbitrary name. The second is the host name (i.e., your virtual
host name). The third parameter is the remote directory where the
repository's contents reside.

(Note that it's also possible to publish to
[Ivy][] repositories, by setting
\`managedStyle\` to \`ManagedStyle.Ivy\`.)

Once those two lines are in your build file, you can publish your
jar file and a corresponding POM file (which SBT generates) with
this command:

    $ sbt publish

If you're \`cross-building\`\_ to multiple Scala versions, you'll
probably want to use this, instead:

    $ sbt +publish

When you run that command, SBT will prompt you, via a Swing GUI
popup window, for your user name and password. Enter your user name
and password on the remote server, and SBT will publish your jar
and POM file to the appropriate place, creating whatever
subdirectories are necessary.

At a minimum, that's all you have to do. I stopped there, because
this setup works quite well for me.

# Saving your credentials

If you get tired of typing your user name and password every time
you publish, you *can* store your credentials in a file or (if
you're brave) in your SBT build file. See the
[SBT Publishing][]
page for details.

(Mark Harrah, SBT's creator, informs me that version 0.7.4 of SBT
will support key-based authentication, as well.)

# Pulling from your Maven repo

This part's easy.

## From SBT

If you're using SBT, you can now start pulling from your own Maven
repo. Suppose you have a package called "org.example.bodacious"
that you've published to your repository. To use version 0.1 of
that package in another SBT project, simply add these lines:

    // Tell SBT about my repository.
    val myRepo = My Maven Repository" at "http://maven.example.org"
    
    // Create a dependency on bodacious.
    val bodacious = "org.example" % "bodacious" % "0.1"

If you cross-built *bodacious*, then use this dependency line,
instead:

    // Create a dependency on bodacious.
    val bodacious = "org.example" %% "bodacious" % "0.1"

The double percent ("%%") tells SBT that the library was
cross-built, and SBT will insert the Scala version into the
artifact automatically.

## From Maven

If you didn't cross build, then you can tell Maven users to use a
dependency like this:

    &lt;dependency&gt;
      &lt;groupId&gt;org.example&lt;/groupId&gt;
      &lt;artifactId&gt;bodacious&lt;/artifactId&gt;
      &lt;version&gt;0.1&lt;/version&gt;
    &lt;/dependency&gt;

If you cross-built *bodacious*, just add the appropriate Scala
version to the artifact. For instance:

    &lt;dependency&gt;
      &lt;groupId&gt;org.example&lt;/groupId&gt;
      &lt;artifactId&gt;bodacious_2.7.7&lt;/artifactId&gt;
      &lt;version&gt;0.1&lt;/version&gt;
    &lt;/dependency&gt;

# Conclusion

Publishing your project to a Maven repository, even a personal one,
makes life easier for other users, especially if your artifact has
dependencies. SBT makes publishing to a Maven repository an utterly
trivial undertaking.

[Scala]: http://www.scala-lang.org/
[SBT]: http://code.google.com/p/simple-build-tool/
[GitHub]: http://www.github.com/
[Maven]: http://maven.apache.org/
[nginx]: http://nginx.org/en/
[SBT Build Configuration]: http://code.google.com/p/simple-build-tool/wiki/BuildConfiguration
[Ivy]: http://ant.apache.org/ivy/
[SBT Publishing]: http://code.google.com/p/simple-build-tool/wiki/Publishing
