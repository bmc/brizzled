---
layout: article
title: Recursive Globbing Considered Cool
tags: bash, shell, zsh, globbing, recursion
date: 2012-01-10 13:45:00
---

I've been using Unix shells for so long that I tend to get locked into a
particular way of doing things. I first started using Unix in 1985, so I've
used a lot of shells, among them the original [Bourne Shell][]; the
[Korn Shell][]; the [C shell][] (and its fork, [Tcsh][]); and, of course,
[Bash][].

Every so often, it makes sense to shake up the status quo. To that end, and
based on some recommendations, I recently switched from Bash to [Zsh][]. While
reading the Zsh documentation, I found that it supports [recursive globbing][].
(Actually, Zsh's globbing features are [even more powerful][], but discussing
all its globby goodness is beyond the scope of this article.)

Anyone who's used [Ant][] in the Java world is familiar with recursive globs.
With this feature enabled in Zsh (which is the default), you can remove all
files ending in `.log` in all directories in and beneath the current working
directory with one simple command:

{% highlight bash %}
zsh$ rm -f **/*.log
{% endhighlight %}    

That command is equivalent to the more traditional (and arcane):

{% highlight bash %}
zsh$ find . -name '*.log' -print0 | xargs -0 rm -f
{% endhighlight %}    

It never occurred to me to see whether Bash supports this feature. (See
previous comment about getting locked into a particular way of doing things.)
So, after seeing it in Zsh, I checked Bash.  Sure enough, Bash 4 has it, too,
but it isn't enabled by default. You have to set the `globstar` shell option to
enable it.

{% highlight bash %}
bash$ cd /var/log
bash$ shopt globstar
globstar        off
bash$ ls **/*.log
ls: cannot access **/*.log: No such file or directory
bash$ shopt -s globstar
bash$ ls **/*.log
bash$ ls **/*.log
appfirewall.log  kernel.log            secure.log
fsck_hfs.log     launchd-shutdown.log  system.log
hdiejectd.log    mail.log              windowserver.log
install.log      notifyd.log           windowserver_last.log
{% endhighlight %}    

Reminder to self: Check for new features now and then.

[Zsh]: http://www.zsh.org/
[Bash]: http://www.gnu.org/software/bash/
[Ant]: http://ant.apache.org/
[Bourne Shell]: http://en.wikipedia.org/wiki/Bourne_shell
[Korn Shell]: http://www.kornshell.org/
[C Shell]: http://en.wikipedia.org/wiki/C_shell
[Tcsh]: http://www.tcsh.org/
[recursive globbing]: http://lorenzod8n.wordpress.com/2007/05/10/recursive-globbing-in-zsh/
[even more powerful]: http://linuxshellaccount.blogspot.com/2008/07/fancy-globbing-with-zsh-on-linux-and.html