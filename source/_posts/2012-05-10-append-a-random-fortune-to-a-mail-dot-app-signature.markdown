---
layout: post
title: "Append a random fortune to a Mail.app signature"
date: 2012-05-10 12:59
comments: true
categories: [AppleScript, Mail.app, apple, mac os x]
---

I recently switched from [Thunderbird][] to [Mail.app][], on my MacBook Pro.
For years, I've been appending random [fortunes][] to the bottom of my email
messages, and I wanted this feature for Mail.app, too.

<!-- more -->

When I used Emacs' [VM] to read mail, I merely had to hack together a tiny
bit of [Elisp](https://github.com/bmc/elisp/blob/master/fortune.el) and wire
it into a VM hook.

When I moved to Thunderbird, I simple wrote a small shell script that to
concatenate a signature prefix file with a random fortune; I then told
*cron*(8) to run that shell script once a minute, to create a new `.signature`
file. I pointed Thunderbird at that generated `.signature` file.

But, as it turns out, you can't point Mail.app at an external `.signature`
file, so the Thunderbird solution won't work.

The answer is to write a small bit of AppleScript (one of the stranger
programming languages I've ever used). The AppleScript script:

* Uses the same signature prefix that the Thunderbird shell script uses.
* Concatenates the contents of that prefix file with the output from my
  `fortune` program.
* Tells Mail.app to replace the named signature. (I have more than one
  signature, and I only want to append a random fortune to one of them.)

Here's the AppleScript code:

{% codeblock Add random fortune to Mail.app signature lang:applescript http://git.io/VRIoCg Source Code %}
{% github bmc/applescripts 06c251a5975d06d5dc1128401d5492c0e7afccc5 %}
{% endcodeblock %}

The final piece of the puzzle is another *cron*(8) entry, in my personal
`crontab`:

    * * * * * osascript $HOME/AppleScripts/fortune-sig.scpt

Conceptually, this solution is the same as the one for Thunderbird; it's just a
different implementation.

[Thunderbird]: http://www.mozilla.org/thunderbird/
[Mail.app]: http://en.wikipedia.org/wiki/Mail_(application)
[fortunes]: https://github.com/bmc/fortunes
[VM]: http://www.wonderworks.com/vm/