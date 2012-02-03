---
layout: post
comments: false
title: "Unintended Consequences"
date: 2007-08-11 00:00
categories: [computers, software, mac os x]
---

This is the story of an unintended interference between two
UI-aware applications. This kind of unexpected interaction happens
a lot with software.

The computer I use at home is a 17" [MacBook Pro][]. The machine's less
than a year old, and yesterday, the display started [acting funny][]. The
display began to look more and more harsh and washed out. By the end of the
day, a typical window looked like this:

![bad Finder display](/images/finder-bad.png)

instead of how it should look:

![good Finder display](/images/finder-good.png)

I was having increasing difficulty reading my email, looking at the
calendar entries in iCal, or doing much of anything. The [photos][] I use
as my background were also looking very unappealing.

"Great," I thought. "A problem with the LCD."

Luckily, the machine is less than a year old, so it's still under
hardware warranty. But I wasn't looking forward to the hassle of
getting it repaired.

Then, I logged out. When the login screen appeared, the display
looked normal again. I logged back in. Initially, the display
looked fine, but then it "went bad" again partway through the login
process.

I created a new account, then logged out of my account and into the
new one. The display looked perfectly normal. I logged out and
logged back into my account again. Once again, partway during the
login, the display went south.

Okay, it clearly was not a hardware failure; there was something peculiar
to my account that was causing the problem. I logged out again. From a
remote [SSH][] window on another machine, I moved all the files out of my
home directory. Then, I logged into the laptop again. Everything looked
perfectly fine. So, I began the tedious process of logging out, restoring a
directory, logging back in, logging out, restoring a directory, logging
back in ...

It didn't take long. As soon as I restored my
`Applications/Preferences` directory, the problem came back.

After digging through the files in that directory (starting with
the most recently modified ones), I finally found a likely
culprit:

    $ cd ~/Library/Preferences
    $ plutil -convert xml1 -o /tmp/foo.xml com.apple.universalaccess.plist
    $ cat /tmp/foo.xml

The constants of that file:

{% codeblock com.apple.universalaccess.plist lang:xml %}
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" 
          "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>PID</key>
        <integer>6282</integer>
        <key>UserAssignableHotKeys</key>
        <array>
                <dict>
                        <key>enabled</key>
                        <true/>
                        <key>key</key>
                        <integer>99</integer>
                        <key>modifier</key>
                        <integer>0</integer>
                        <key>sybmolichotkey</key>
                        <integer>64</integer>
                </dict>
                <dict>
                        <key>enabled</key>
                        <true/>
                        <key>key</key>
                        <integer>49</integer>
                        <key>modifier</key>
                        <integer>1572864</integer>
                        <key>sybmolichotkey</key>
                        <integer>65</integer>
                </dict>
        </array>
        <key>closeViewDriverMouseZoomSwitch</key>
        <true/>
        <key>closeViewScrollWheelToggle</key>
        <true/>
        <key>contrast</key>
        <real>0.30812768</real>
</dict>
</plist>
{% endcodeblock %}

The culprit:

{% codeblock lang:xml %}
<key>contrast</key>
<real>0.30812768</real>
{% endcodeblock %}

I removed the `contrast` keyword and value and recreated the binary file:

{% codeblock lang:shell %}
$ plutil -convert binary1 -o com.apple.universalaccess.plist /tmp/foo.xml
{% endcodeblock %}

After logging out and logging back in, everything was perfect
again.

But how did the Universal Access contrast value suddenly get set? I
decided to look at the Universal Access preferences screen, in the
System Preferences application:

![Universal Access](/images/universal-access.png)

Looking at that screen, I knew immediately what had happened. As the
Universal Access Preference screen clearly shows, the default keyboard
shortcut for boosting the screen contrast is
Command-Option-Control-*period*. I'd been typing that key sequence. Why?
Well, I recently installed [Quicksilver][], the [Leatherman][] of Mac OS X
applications. Using Quicksilver's iTunes plug-in, I'd created keyboard
shortcuts so I could increase and decrease the iTunes volume settings, skip
to the next or previous song, and pause and resume iTunes without having to
switch to the iTunes window. I often pause whatever I'm playing on iTunes
when I pick up the phone, and that day had been a fairly busy phone day;
it's extraordinarily convenient and efficient to pause and resume iTunes
from the keyboard. The keyboard shortcut I'd chosen for the pause/resume
action was Command-Option-Control-*period*, chosen *deliberately* so that
it wouldn't interfere with Emacs keys, the hot keys in my [Java IDE][], and
other applications. Little did I know that I'd chosen the exact same key
sequence used by the Mac OS X Universal Access system to **increase the
screen contrast.** Every time I paused or resumed iTunes, I boosted the
screen contrast a little bit, until finally, the screen looked like crap.

A little experimentation showed that unchecking the "Enable access
for assistive devices" checkbox had no effect on this feature; even
with that checkbox unchecked, the Command-Option-Control-*period*
shortcut still increased the screen contrast. I didn't want to
change my iTunes shortcut, because it's a key sequence I'm not
likely to hit by accident. (I'm sure that's why it was also chosen
for Universal Access's "Increase contrast" function.) To fix the
problem, I had to disable the corresponding Universal Access
keyboard shortcut entirely, via System Preferences &gt; Keyboard
and Mouse &gt; Keyboard Shortcuts. For good measure, I disabled
*all* the Universal Access keyboard shortcuts:

![Universal Access keyboard shortcuts](/images/keyboard-shortcuts.png)

Maybe this blog entry will save someone else some time...

[MacBook Pro]: http://www.apple.com/macbookpro/
[acting funny]: http://books.google.com/books?id=BzRfkR51i60C&amp;dq=%22acting+funny%22&amp;printsec=frontcover&amp;source=web&amp;ots=BGoE6aSChA&amp;sig=jgdJrGfy87AYu5kkU8mDNrdTyYQ
[photos]: http://www.clapper.org/bmc/photography/gallery/
[SSH]: http://www.openssh.org/
[Quicksilver]: http://quicksilver.blacktree.com/
[Leatherman]: http://www.leatherman.com/
[Java IDE]: http://www.netbeans.org/
