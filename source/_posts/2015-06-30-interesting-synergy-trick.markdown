---
layout: post
title: "Interesting Synergy trick"
date: 2015-06-30 10:57
comments: true
categories: [synergy]
---

Using [Synergy](http://www.synergy-project.org/), it's relatively easy
to configure the arrangement in the following diagram:

{% img image-center blend-in /images/synergy-layout.png Synergy layout %}

<!-- more -->

I have two laptops, one Linux and one Mac. I've connected a second
monitor to each laptop. The two external monitors sit next to one
another, on the right of my desk. The two laptops sit next to one
another, on the left of my desk. I wanted to be able use Synergy
as follows:

* The Mac owns the keyboard and mouse. Thus, it's the Synergy _server_.
* The Linux laptop is the sole Synergy _client_.
* When the mouse hits the right edge of the Mac's external monitor,
  control should pass to Linux laptop, and the mouse pointer should
  appear on the Linux laptop's external monitor.
* When the mouse hits the left edge of the Mac's built-in laptop screen,
  control should pass to Linux laptop, and the mouse pointer should
  appear on the Linux laptop's built-in laptop screen.

Here's the Synergy configuration I use on the Mac (the Synergy server).
I've replaced the Mac hostname with "hostmac" and the Linux hostname
with "hostlinux".

```
section: screens
    hostmac:
    hostlinux:
      alt = super
      super = alt
end
section: links
   hostlinux:
       right = hostmac
       left = hostmac
   hostmac:
       left = hostlinux
       right = hostlinux
end
```

The Synergy configuration on the Linux system (the Synergy client) is
similar:

```
section: screens
    hostlinux:
    hostmac:
end
section: links
   hostlinux:
       right = hostmac
       left  = hostmac
   hostmac:
       left = hostlinux
       right = hostlinux
end
```

For more information, see:

* <http://superuser.com/questions/288743>
* <http://community.linuxmint.com/tutorial/view/1660>

One issue I've noticed: If the screen saver kicks in on the Mac, when I
exit the screen saver, the mouse acceleration on the Linux box (through
Synergy) is often dramatically faster. Restarting the Synergy server
(on the Mac) fixes the problem.

