---
layout: post
comments: true
title: "Where does this thing go?"
date: 2011-10-31 00:00
categories: [git, svn, subversion, programming, bzr, bazaar, mercurial, hg]
---

Quick: You're in a local copy of a [Git][], [Subversion][], [Mercurial][]
or [Bazaar][] repository. How do you figure out the URL of the remote
(primary) repository?

[Git]: http://git-scm.com/
[Bazaar]: http://bazaar.canonical.com/
[Mercurial]: http://mercurial.selenic.com/
[Subversion]: http://subversion.apache.org/

## Git

    git config --get remote.origin.url

or, if you want all of them:

    git remote -v

If you put the command in a shell script called `git-url`, you can simply
invoke it like this:

    git url

## Subversion

    svn info | grep -i url

## Mercurial

    hg paths default

## Bazaar

    bzr info 2>&1 |grep 'parent branch'

Shell scripts or aliases (e.g., `svnurl`, `bzrurl`, `hgurl`, `git-url`)
are useful finger-savers for these commands.
