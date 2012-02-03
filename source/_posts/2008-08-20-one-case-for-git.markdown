---
layout: post
comments: false
title: "One case for git"
date: 2008-08-20 00:00
categories: [subversion, git, programming, revision control]
---

The more I play with [git][], the more I like the idea of distributed
source control. Here's one scenario where it just seems more ... natural.

I'm working on some code on my [Ubuntu][] development box. I suddenly
realize I can't really test it on my machine, because it needs a pristine
environment that more closely mimics our run-time servers. So, I fire up my
(checkpointed) [VMWare][] Ubuntu instance so I can run an install over
there.

I want my code over there, too. But I'm not ready to check that code into
the [Subversion][] repository yet. (We're currently using Subversion at
work.)

Two solutions immediately spring to mind:

1. Create a Subversion branch for my code, switch my local development tree
   to that branch, and check my code into Subversion. Then, on the pristine
   virtual machine, check that branch out of Subversion and install that
   code. Okay, this'll work. But I find merging in Subversion to be
   annoying, especially if you're doing multiple merges back from your
   branch (which I might have to do here).
2. Use [rsync][] to copy the uncommitted code from my development branch
   over to the pristine machine. This will also work, of course.

If we were using something like [git][], though, there'd be a more
natural-feeling solution. I could check my code in locally, without pushing
it to the master server. Then, from the pristine machine, I could simply
pull that code over from my development box, just as if I were checking it
out from the master server. As I fix problems with the code, I commit more
local changes and pull those check-ins over to the test machine. Later,
when everything seems ready for prime time, I simply push the code from my
development machine into the master server.

Distributed version control systems like [git][] seem to handle that kind
of situation naturally and efficiently. I realize that this approach may
not seem all that much different from #1, above, but it just *feels*
cleaner and closer to the problem I'm actually trying to solve.

[Ubuntu]: http://www.ubuntu.com/
[VMWare]: http://www.vmware.com/
[Subversion]: http://subversion.tigris.org/
[rsync]: http://en.wikipedia.org/wiki/Rsync
[git]: http://git.or.cz/
