---
layout: article
title: Getting Delicious bookmarks to Diigo
tags: del.icio.us, diigo, bookmarks
date: 2010-12-17 00:00:00
---

On 16 December, 2010, a [leaked slide][], purportedly from [Yahoo!][]
all-hands meeting, seemed to indicate that Yahoo! was planning to shut
down its popular [Delicious][] bookmarking site. Yahoo [denies the rumor][],
but does state that Delicious is not a "strategic fit at Yahoo!".

[leaked slide]: http://mashable.com/2010/12/16/leaked-slide-shows-yahoo-is-killing-delicious-other-web-apps/
[Yahoo!]: http://www.yahoo.com/
[Delicious]: http://www.delicious.com/
[denies the rumor]: http://mashable.com/2010/12/17/state-of-delicious/

Loads of people are now looking for alternatives to Delicious. I have
settled on [Diigo][], for these reasons:

* It has a extension for [Google Chrome][], the browser I use most these days,
  as well as a [toolbar](http://www.diigo.com/tools/toolbar) that will work
  with other browsers.
* It has an [API][Diigo API], though the API is not very well documented.
* It supports essentially the same features as Delicious, with additional
  capabilities.
* It has both a free and a [premium](http://www.diigo.com/premium) service.
* It works on Linux, not just Mac and Windows. (I use all three, though I
  spend most of my time on my Mac laptop or on Linux.)

[Diigo]: http://www.diigo.com/
[Google Chrome]: http://www.google.com/chrome/
[Diigo API]: http://www.diigo.com/tools/api

The trick, of course, is getting my Delicious bookmarks *into* Diigo. Diigo
has a web-based service for importing one's Delicious bookmarks, but it
hasn't worked for me so far. It turns out, however, that it's not difficult
to hack together a quick program to do it manually. Starting with the
[diigo.py][] file at [slumpy.org](http://slumpy.org), I hacked together a
quick [Python][] script, [delicious2diigo.py][].

[diigo.py]: http://slumpy.org/files/diigo.py_.txt
[delicious2diigo.py]: delicious2diigo.py
[Python]: http://www.python.org/

To use it, download the script and save it. Then, edit the credential
constants at the top of the file to correspond to your Delicious and Diigo
login credentials.

If you call it with no arguments:

{% highlight bash %}
    $ python delicious2diigo
{% endhighlight %}

it will attempt to download your Delicious bookmarks (as XML), parse them,
and upload them to Diigo.

However, if you have already downloaded your Delicious bookmarks as XML,
you can simply pass the XML file directly to the script:

{% highlight bash %}
    $ python delicious2diigo bookmarks.xml
{% endhighlight %}

The script can take awhile to run, if you have a lot of bookmarks. Diigo's
API apparently accepts up to 100 bookmarks at a time, so the script breaks
your bookmarks into chunks of 100. I noticed that Diigo's API web site
occasionally throws HTTP 503 errors (perhaps because it's overloaded), so
the script retries an upload if it receives that error. All other errors
cause it to abort with an exception.

I used the script to upload several hundred Delicious bookmarks, and it
worked fine for me, preserving the bookmarks' titles, URLs and tags. Your
mileage, of course, may vary.

The script is below. It's also [available as a GitHub gist][].

[available as a GitHub gist]: https://gist.github.com/746123

<script src="https://gist.github.com/746123.js"> </script>
