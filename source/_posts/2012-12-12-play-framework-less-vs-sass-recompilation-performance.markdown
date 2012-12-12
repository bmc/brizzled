---
layout: post
title: "Play Framework: LESS vs. Sass Recompilation Performance"
date: 2012-12-12 11:03
comments: true
categories: [playframework, scala, programming, css]
toc: true
---

# Overview

Lately, I've been building some web applications using version 2.0.4 of
the [Play Framework][]. Overall, I find I like the framework. In my
opinion, it compares favorably with technologies like [Django][]
and [Ruby on Rails][], especially for those of us who find that compile-time
type safety provides useful benefits.

However, one area where Play lags far behind the competition is in CSS asset
compilation.

So, I decided to run some tests...

<!-- more -->

By default, Play supports the [LESS][] dynamic stylesheet language, which
supports variables, mixins, nested rules, and other useful features; LESS
stylesheets compile down to standard CSS stylesheets. Rails uses [Sass][] to
provide a similar capability. Indeed, there are more similarities than
differences between the Sass and LESS languages.

Both frameworks allow you to edit a CSS source (LESS or Sass) while the
framework is running in development mode. When you reload your web site,
from a browser, the framework automatically recompiles the LESS or Sass source,
producing the CSS files that must be served to the browser.

In Play, LESS compilation is *slow*. Extremely slow. It's also buggy,
frequently producing JVM core dumps on my Linux machine.

# Background

The standard LESS translator is written in Javascript. Under the covers, Play
uses Mozilla [Rhino][], a Javascript interpreter that's written in Java, to run
the Javascript translator directly within the Java VM, to produce both a
regular CSS file and a minified CSS file.

In addition, Play's LESS compilation strategy doesn't do any form of
dependency management. The **Managed assets** section of
<http://www.playframework.org/documentation/2.0.4/Assets> reads:

> By default play compiles all managed assets that are kept in the app/assets
> older. The compilation process will clean and recompile all managed
> assetsregardless of the change. This is the safest strategy since tracking
> dependencies can be very tricky with front end technologies.

That documentation also states:

> Note if you are dealing with a lot of managed assets this strategy can be
> very slow. For this reason there is a way to recompile only the change file
> and its supposed dependencies. You can turn on this experimental feature by
> adding the following to your settings:
>
>     incrementalAssetsCompilation := true

The `incrementalAssetsCompilation` key (an SBT setting) isn't actually
available, though, despite being documented. According to
<http://stackoverflow.com/questions/12368679>, the feature didn't make it
into Play 2.0.3 (or 2.0.4).

For the intrepid reader, the code that does the LESS-to-CSS translation is in
the following source file:

<https://github.com/playframework/Play20/blob/master/framework/src/sbt-plugin/src/main/scala/less/LessCompiler.scala>

# Hypotheses

There are several possible causes for the slowness, including:

* Is the LESS compiler slower than the Sass compiler?
* Is running LESS via Rhino slower than running the `lessc` command (via
  Node.js) on the same files?
* How much is [Twitter Bootstrap][] contributing to the problem?

I tested the first two. As for Twitter Bootstrap, I'm certain that it *is*
contributing. I'm keeping the Bootstrap source LESS files in my
`app/assets/stylesheets` tree, largely because it's easier to modify
Bootstrap's `_variables.less` that way. Twitter Bootstrap is *big*. Twitter
Bootstrap's LESS files have 5,125 lines of LESS (including about 770 lines of
white space and comments). My LESS files add another 991 lines (about 240 of
which are white space and comments).

Using a precompiled Bootstrap would probably make a significant difference in
LESS recompilation, but I'm not interested in doing that until I've exhausted
other possibilities, because of the convenience of working with the Bootstrap
sources.

# Tests

I ran the following tests, to try to get an idea of what to do next.
Note that a [graph](#graph-of-results) follows the test descriptions.

## Test 1: Less recompilation via Play

This test is simple: Run a script that touches one of my `.less` input files,
then attempt to access a non-authenticated page in the application. Play
detects the modified LESS source file and invokes its internal Rhino-based
recompilation of all LESS files.

Here's the quick-and-dirty shell script I used:

{% codeblock lang:bash %}
#!/bin/bash

OUT=times.out
TIME=/usr/bin/time
URL=http://localhost:9000/splash
FILE=app/assets/stylesheets/main

timestamp()
{
    date '+%H:%M:%S'
}
iterations=${1:-10}
>$OUT

# In case Play was restarted, warm it up first with a request we're not timing.
echo "Warming up the server..."
curl -o /dev/null --stderr /dev/null $URL

echo "Running tests."

for (( i = 0; i <= $iterations; i += 1 )); do
    echo "[$(timestamp)] start test #$i"
    if [ -f $FILE.less ]; then
        echo "   Touching $FILE.less"
        touch $FILE.less
    elif [ -f $FILE.scss ]; then
        echo "   Touching $FILE.scss"
        touch $FILE.scss
    else
        echo "Huh? Can't find $FILE.scss or $FILE.less" >&2
        exit 1
    fi

    $TIME --f '%e' curl -o /dev/null -q --stderr /dev/null $URL 2>>$OUT
    echo "[$(timestamp)] end test #$i"
done
{% endcodeblock %}

The test measures wall clock time, because that's the measurement that
matters to me, as a developer: How long I have to wait for the page to
reload, after I've modified a LESS source file.

I ran this test with 50 iterations.

Aside: This test was surprisingly difficult to complete, because the Java 7 VM
on my Linux system kept dumping core. Sometimes, I'd only get two requests to
succeed, before the JVM crapped out, presenting me with one of those
`hs_err_pidXXXX.log` files. Some of the errors are listed, below.

### Resulting data:

* **Mean**: 19.63 seconds
* **Median**: 19.48 seconds
* **Standard Deviation**: 1.45

Here are some of the JVM errors, when Play barfed during the tests:

    Problematic frame:
    J  org.mozilla.javascript.ScriptRuntime.toBoolean(Ljava/lang/Object;)Z

    Problematic frame:
    J  org.mozilla.javascript.ScriptRuntime.toObjectOrNull(Lorg/mozilla/javascript/Context;Ljava/lang/Object;Lorg/mozilla/javascript/Scriptable;)Lorg/mozilla/javascript/Scriptable;

    Problematic frame:
    J  org.mozilla.javascript.ScriptRuntime.toBoolean(Ljava/lang/Object;)Z

    Problematic frame:
    j  org.jboss.netty.channel.SimpleChannelUpstreamHandler.handleUpstream(Lorg/j   oss/netty/channel/ChannelHandlerContext;Lorg/jboss/netty/channel/ChannelEvent;   V+185

    Problematic frame:
    J  org.mozilla.javascript.ScriptableObject.accessSlot(Ljava/lang/String;II)   org/mozilla/javascript/ScriptableObject$Slot;

I didn't see core dumps like these with the other tests, and I saw plenty of
them with the embedded Rhino-based LESS conversion. Clearly, there are problems
with Play's use of Rhino.

## Test 2: Less recompilation via `lessc`

In this test, I ran the following script 50 times:

{% codeblock lang:bash %}
#!/bin/sh
for i in $(find app/assets/stylesheets -name '[^_]*.less')
do
    lessc $i >/tmp/foo.css
    lessc --compress $i >/tmp/foo.min.css
done
{% endcodeblock %}

The code runs `lessc` twice, for each input file, generating both a regular
and a compressed version of the CSS output, since that's what Play does.

### Resulting data:

* **Mean**: 5.34 seconds
* **Median**: 5.1 seconds
* **Standard Deviation**: 0.91


## Test 3: Sass, via Play

For this test, I installed the [Play-Sass][] plugin, which is implemented as
an [SBT][] plugin. This plugin implements automatic recompilation of Sass
assets, via the `sass` command that's installed with the Ruby `sass` gem.

I then:

* pulled down John W. Long's [sass-twitter-bootrap][] repository
* removed the Bootstrap LESS files, replacing them with Long's Bootstrap
  Sass equivalents
* installed the `sass` gem in a separate [rvm][] [gemset][]
* spent about an hour converting my LESS files to Sass.

Once I'd finished and verified that the web application still worked, I ran
the first script again. Like the first one, script "warmed up" the
server, touched one of my Sass files, and then issued a query for a page,
forcing Play to recompile the Sass files.

### Resulting data:

* **Mean**: 8.34 secondsb
* **Median**: 8.27 seconds
* **Standard Deviation**: 0.39

# Graph of Results

{% img /images/2012-12-12-graph.png %}

# Conclusions

1. I should write a [LESS][] compilation SBT plugin that compiles the LESS
   files via the `lessc` command. (This is what the [Play-Sass][] plugin does.)
   If I were to do so, and assuming I could easily disable Play's default
   LESS compilation, the plugin should be significantly faster, based on these
   test results.

2. Before such a plugin exists, switching from [LESS][] to [Sass][] provides
   a significant increase in CSS compilation speed.

3. Using a precompiled version of Bootstrap might provide the best improvement,
   since it's a huge chunk of the LESS code that gets compiled each time.

[rvm]: http://rvm.io/
[rvm gemset]: https://rvm.io/gemsets/basics/
[sass-twitter-bootrap]: https://github.com/jlong/sass-twitter-bootstrap
[SBT]: http://scala-sbt.org
[Play-Sass]: https://github.com/jlitola/play-sass
[Twitter Bootstrap]: http://twitter.github.com/bootstrap/
[Rhino]: https://developer.mozilla.org/en-US/docs/Rhino
[Play Framework]: http://playframework.org/
[Django]: http://www.djangoproject.com/
[Ruby on Rails]: http://rubyonrails.org/
[Play LESS]: http://www.playframework.org/documentation/2.0/AssetsLess
[LESS]: http://lesscss.org/
[Sass]: http://sasslang.org/