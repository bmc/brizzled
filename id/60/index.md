---
layout: article
title: SpotlightFS
tags: mac-os-x, spotlightfs, spotlight, unix, computers
date: 2007-02-04
---

Okay, this one hits the Unix geek in me right where I live.

Some guy at [Google][] recently ported [FUSE][] (Filesystem in Userspace)
to [Mac OS X][]. FUSE is a clean and simple API for implementing file
systems (or file system-like views of other things) in Linux, and loads of
people have written file systems implemented on top of FUSE. FUSE has also
been ported to FreeBSD.

Anyway, I installed it awhile ago. It's pretty cool. The SSH FUSE file
system is useful; I now routinely mount my home directory from our
development machine in the corporate office to my Mac, via sshfs. (This
technique obviously works really well from a Linux client machine, too.)

Well, the MacFUSE geek recently released another cool FUSE file system:
[SpotlightFS][]. [Spotlight][] is the pervasive Mac search engine tool;
from the Mac desktop, you can use Spotlight to "find anything on your
computer as quickly as you can type" (Apple's words). [Vista][] has
something similar, or so [I've read][].

With SpotlightFS, I get a "file system" mounted under
`/Volumes/SpotlightFS`. If I create a directory under there, SpotlightFS
performs a search on the term(s) in the directory name and makes links to
all files that match the search. For instance:

    $ mkdir /Volumes/SpotlightFS/google
    $ ls /Volumes/SpotlightFS/google
    :Applications:Google Video Player.app
    :Applications:SpotlightFS.app
    :Library:Widgets:Google.wdgt
    :Users:bmc:Library:Application Support:CrossOver:Bottles:win98:drive_ ...
    :Users:bmc:Library:Application Support:CrossOver:Bottles:win98:drive_ ...
    :Users:bmc:Library:Application Support:Firefox:Profiles:ti6krs2m.default:cookies.txt
    :Users:bmc:Library:Application Support:Google Video Player
    :Users:bmc:Library:Application Support:Google Video Player:Uninstall Google Video Player.app
    :Users:bmc:Library:Caches:Metadata:Safari:1C0B4B8D-77E5-4305-A776-83DC30769E13.webbookmark
    :Users:bmc:Library:Mail:IMAP-bmc@mail.inside.clapper.org:NETBEANS ...
    ...

I can also create virtual folders ("smart folders") on the fly;
they don't show up in an "ls", but they do return results. All I
have to do is list something under the
`/Volumes/SpotlightFS/SmarterFolder` directory. Thus, this one
command does exactly what the two commands, above, do:

    $ ls /Volumes/SpotlightFS/SmarterFolder/google

Okay, so this seems kind of silly at first; why bother, when there's
friendlier Spotlight GUI integration on the desktop? Well, in two words:
power and flexibility. For instance, tonight, my daughter was sitting next
to me in my office, playing in [TuxPaint][], a kid-oriented computer
drawing program that'll run on the Mac. Meanwhile, I was using the
keyboard, mouse and monitor attached to my employer-supplied Linux
workstation. Naturally, I had a remote login window to the Mac on my Linux
desktop. I was searching for a file that had a particular phrase in it.
Since my daughter had the desktop, I couldn't use the Spotlight GUI
interface. Normally, in Unix, I'd do something like

    $ find . -type f | xargs grep -l foobar

to get a list of files containing "foobar". But Spotlight is more
metadata-aware than grep and, in this particular case, was more
likely to get me what I wanted. With SpotlightFS, I was able to
use:

    $ ls /Volumes/SpotlightFS/SmarterFolder/foobar

There's the flexibility: the ability to issue powerful Spotlight searches
from a simple remotely logged-in command line, without requiring access to
the Mac OS X desktop.

As for power, well, I'm already imagining ways that I might integrate
Spotlight into shell and Python scripts.

[Google]: http://www.google.com/
[FUSE]: http://fuse.sourceforge.net/
[Mac OS X]: http://code.google.com/p/macfuse/
[SpotlightFS]: http://code.google.com/p/macfuse/wiki/MACFUSE_FS_SPOTLIGHTFS
[Spotlight]: http://www.apple.com/macosx/features/spotlight/
[Vista]: http://www.microsoft.com/windows/products/windowsvista/default.mspx
[I've read]: http://www.eweek.com/article2/0,1895,1842175,00.asp
[TuxPaint]: http://www.tuxpaint.org/
