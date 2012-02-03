---
layout: post
comments: false
title: "eventter: A lightweight notification framework"
date: 2009-01-07 00:00
categories: [python, udp, notification, messaging, programming]
---

A short time ago, colleague and friend, [Mark Chadwick][], put together an
interesting little Python tool he calls [*eventter*][eventter]. Basically,
it's a small API around a simple [UDP][] broadcast messaging protocol. An
eventter sending process emits a message, and all eventter listeners on the
local network receive it.

If that were it, eventter wouldn't be all that interesting. However, Mark
wrote an example receiver that forwards any message it receives to
[DBUS][]. Run that receiver on a Linux machine under Gnome, and any message
sent via the eventter framework shows up as a small, temporary Gnome
notification.

I added two more sample receivers, one for [Growl][] (for Mac OS X
machines) and one for [Snarl][] (for Windows machines). So the *eventter*
distribution has adapters for Growl-like services on three major platforms.

"But what's the point?" you ask. Well, we've actually found some
interesting uses for *eventter* at the office. For instance:

- Mark installed an *eventter* command client as a [subversion][] post-commit
  hook. Now, whenever anyone commits anything to our source code
  repository, everyone running an *eventter* receiver sees the commit message
  for a few seconds.
- I added a similar command line client to our [CruiseControl][] continuous
  build server. Now, whenever a build completes, the name, version and
  status of the build (success or failure) are emitted via *eventter*.

I also modified my local copy of the Growl and DBUS receivers so they log
received messages to a file. That way, I can quickly review what's happened
over the last hour or so, just by looking at that log file.

The UDP broadcast messages even propagate over our [VPN][], so someone
working from home can still see them.

I've become rather fond of this tool. It's simple, clean,
well-written, easy to adapt, and surprisingly useful.

[Mark Chadwick]: http://www.hipstersinc.com/
[eventter]: http://github.com/markchadwick/eventter/tree/master
[UDP]: http://en.wikipedia.org/wiki/User_Datagram_Protocol
[DBUS]: http://dbus.freedesktop.org/
[Growl]: http://growl.info/
[Snarl]: http://www.fullphat.net/index.php
[subversion]: http://subversion.tigris.org/
[CruiseControl]: http://cruisecontrolrb.thoughtworks.com/
[VPN]: http://openvpn.net/
