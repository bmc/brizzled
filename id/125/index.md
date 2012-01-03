---
layout: article
title: "Details, Details"
tags: humility, programming, bug
date: 2011-11-06 00:00:00
---

About 15 years ago, I wrote a network server that could talk to a Visa point of
sale (POS) box. The POS box was a modem-like device that connected to an
[RS-232][] port. POS-aware software could use the box to send credit card
transactions to a bank, for processing.

We needed a network server that could accept credit card transactions from a
[NetWare][] client and route them through the POS box, handling all the
timeouts, retries, and errors that might occur. Since no such software existed,
my  job was to write it. Over the course of a month or so, that's what I did.
Written in C++, the code ran on Solaris and [UnixWare][]. The plan was to 
deploy it on UnixWare, which could handle [IPX and SPX][], the network
protocols underneath NetWare.

I tested the hell out of that thing, until it was bulletproof--or, so I
thought. It was **so** bulletproof, in fact, that it basically never crashed.
Eventually, it kind of got lost in the machine room. It was running on a PC,
under UnixWare. The operating system was pretty stable, as was my server.
At some point, someone took the monitor away, for some other purpose, so the
machine ran headless. Over time, it gradually got shoved behind some other 
machines.

It ran that way for a few years, never crashing. The server room was wired to a
backup generator, in case of power failure, so the machine just stayed up, and
people apparently started taking the Visa network service for granted.  During
that interval, I left the company. A year or so after I left, a friend sent me
an email, informing me that the Visa POS server had finally crashed.

Worse: *No one could find the machine.*

It had run so well, for so long, that it was buried, sans monitor, somewhere in
the machine room.

Ultimately, they did locate it. It had crashed because of one Achilles' heel 
I'd inadvertently left in the code: I had forgotten to roll the log files. It
took several years, but eventually the log files grew too big and filled the 
disk. At that point, the whole thing came crashing down.

On the one hand, I was proud to have written a piece of software that ran so
well that its users and administrators simply forgot the machine even existed.
On the other hand, lest I become too arrogant, that same piece of software
ultimately crashed, and caused a minor panic, because of one small defect.

There's a nice, neat lesson in there somewhere.

[RS-232]: http://en.wikipedia.org/wiki/RS-232
[UnixWare]: http://en.wikipedia.org/wiki/UnixWare
[IPX and SPX]: http://en.wikipedia.org/wiki/IPX/SPX
[NetWare]: http://en.wikipedia.org/wiki/Novell_NetWare
