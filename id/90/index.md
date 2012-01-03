---
layout: article
title: Mac OS X, iTerm, bash key bindings, and muscle memory
date: 2009-05-16 00:00:00
tags: mac-os-x, unix, bash, iTerm, key-bindings, Terminal.app
---

I've been using Unix-like systems for a long time, and one of the
attractions of going with a Mac (aside from being able to run
Photoshop on a platform other than Windows) is that Mac OS X is,
essentially, a flavor of Unix.

Naturally, as befits someone who's been using Unix systems for
nearly a quarter century, I spend time a lot of time at the command
line, even on a Mac. But there, my muscle memory betrays me.

Instead of using the Mac's Terminal.app for my command-line adventures, I
use [iTerm][], an enhanced terminal emulator I like better. The problem is,
though, that iTerm intercepts many of the keys my fingers want to use with
*bash*. I use the *bash* Emacs key bindings, and my fingers are accustomed
to key bindings like:

- **Alt-F** to move forward a word
- **Alt-B** to move backward a word
- **Alt-D** to delete the word ahead of the cursor

etc.

There are plenty of tips on the Internet on how to map Option-F to
*forward-word*, Option-B to *backward-word*, and the like. There's
[one here][], for instance, and [another one here][]. But the authors of
those hints are substituting the Option key for the Alt key. Using Option
conflicts with my muscle memory: On a Mac the Option key doesn't occupy the
same position as the Alt key on a "normal" keyboard. Instead, it occupies
the same positions as the Windows key. The Mac's Command key is in the
position of the Alt key. Because of these key positions, and from years of
using Linux and FreeBSD systems, my fingers invariably attempt to use
Command-F for *forward-word*; in iTerm, Command-F invokes a search dialog I
never use. Similarly, my fingers use Command-B for *backward-word*, which
brings up an iTerm bookmark drawer I also have no use for.

It turns out, though, that there's a solution, as long as you don't mind
overriding the key bindings for the search dialog and the bookmarks drawer.
(As I noted, I don't use them, so I don't mind.)

First, from the iTerm menu, select
**Bookmarks > Manage Profiles**. In the resulting dialog, expand
the *Keyboard Profiles* tree:

![iTerm Profiles dialog](/images/iTerm-profiles-dialog.png)

Select the keyboard profile you use with your terminal profiles.
(For most people, that will be "Global").

Then, on the right side, click the "+" icon to add a keybinding.
You want to map **Command-F** to the escape sequence "ESC f", to
tell *bash* to move the cursor forward one word. To map the "F"
key, you have to specify its ASCII hexadecimal code, which is 66.
(Type `man ascii` in your iTerm bash shell for a list of ASCII
codes, if you don't happen to remember them.)

In the dialog box:

-   Select "hex code" from the **Key** drop-down, and type "66" in
    the text box next to it.
-   Then, check the **Command** check box.
-   In the **Action** drop-down, select "send escape sequence".
-   In the text box that shows up below **Action**, type "f".
-   Finally, check the **High interception priority** checkbox.
    This step is critical if you want to override the default behavior
    of the Command key.

![Configuring a key binding in iTerm](/images/iTerm-keybinding.png)

Then, click **OK**. That should be all you need to do. I leave the
remaining key bindings as an exercise for the reader.

**UPDATE 23 December, 2009**

In an email, Andrew McDermott writes:

> I too struggled with this and (I think) eventually fixed this. Take
> a look at the following:
> 
> `cmd-key-happy` -- swap cmd and alt keys in Terminal.app

[iTerm]: http://iterm.sourceforge.net/
[one here]: http://ninjamonkeys.co.za/forum/index.php?topic=598
[another one here]: http://splatteredbits.com/tips/move-from-word-to-word-in-iterm
[iTerm Profiles dialog]: /static/iTerm-profiles-dialog.png "iTerm Profiles dialog"
[Configuring a key binding in iTerm]: /static/iTerm-keybinding.png "Configuring a key binding in iTerm"
