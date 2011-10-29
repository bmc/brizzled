---
layout: article
tags: django, blogging, vps, python, programming
title: Django blog
date: 2008-07-27
---

As previously noted, this blog now runs under [Django][], on the lowest-end
[VPS][] that's available from [VPSLink][]. The virtual machine (a [Xen][]
instance) has 64Mb of RAM, 2Gb of disk, and some portion of the hardware
CPU.

This little project has been a very good, well-defined, small,
controlled laboratory for learning more about Django. Since we're
using Django at [work][], it's helpful
for me to know more about it.

Django has a *lot* of built-in capabilities, and I've only begun to
scratch the surface. For instance:

- It has its own rich [template][] language that supports, among other
  things, template inheritance.
- It has a built-in, powerful, yet easy-to-use [ORM][].
- It uses an [MVC][]-like "model-view-template" approach that, while
  slightly different from true MVC, still keeps business logic separate
  from presentation logic.
- It has built-in caching support for a variety of caching technologies
  (disk, database, in-process memory, and [memcache][]).
- It supports any RDBMS that Python supports.
- It has *loads* of capabilities, but doesn't force you to use anything you
  don't need. It's a lot like [Spring][] in that regard: You use what you
  need, and add new capabilities as the situation requires.

The low-end VPS I use isn't a super high performer, so I've chosen
to use a [SQLite][] database for my blog.
This decision is proving to be a good one, for a couple reasons:

- The database requirements of my blog aren't especially demanding. 99% of
  the time, Django is simply reading from the database to serve content.
  And since I'm using caching, it's not even reading from the database
  every time.

- SQLite stores its database in a single file, which means I can easily
  back it up. It also means I can write my blog posts to a faster local
  Django mirror, and then simply upload the new database file when I'm
  ready to publish. (This is, in fact, exactly what I do.)

- SQLite doesn't use a database server; it's entirely a file protocol. Not
  having to run an additional [PostgreSQL][] or [MySQL][] server on the VPS
  is a Good Thing.

In addition to all those advantages, though, Django has proved to
be an *excellent* platform for incremental development; I am able
to add features to my blog slowly, without ripping everything
apart. In addition, I can add new capabilities without writing a
whole lot of code. I wrote the blog software myself, but Django
does a lot of the heavy lifting. As a result, I was able to build a
fully-functioning blog engine in less than a day, using about 400
lines of Python and a little more than 400 lines of template code.

That's just outrageous.

Running Django on such a small VPS instance poses some performance
issues. Here's what I've done to alleviate some of the problems.

* Followed the VPSLink wiki suggestions on
  [tuning Apache for low-memory configurations][].
* Added "Accept-Encoding: [gzip][]", Expires, and Etags headers to
  Apache and Django.
* Added [server-side caching][] to Django. As noted above, Django support
  several different ways to cache rendered pages. I'm using in-process
  memory (`locmem`) at the moment.
* Reduced the number of entries on the main blog page from 20 to 5. (The
  entire archive is available through various other links, so no harm.)

These measures seem to have improved performance a bit.

[previously noted]: /bmc/blog/id/72
[Django]: http://www.djangoproject.com/
[VPS]: http://onlinebusiness.about.com/od/webhosting/g/vps.htm
[VPSLink]: http://www.vpslink.com/
[Xen]: http://www.xen.org/
[work]: http://www.invitemedia.com/
[template]: http://www.djangoproject.com/documentation/templates/
[ORM]: http://en.wikipedia.org/wiki/Object-relational_mapping
[MVC]: http://en.wikipedia.org/wiki/Model-view-controller
[memcache]: http://www.danga.com/memcached/
[Spring]: http://www.springframework.org/
[SQLite]: http://www.sqlite.org/
[PostgreSQL]: http://www.postgresql.org/
[MySQL]: http://www.mysql.org/
[tuning Apache for low-memory configurations]: http://wiki.vpslink.com/index.php?title=Low_memory_MySQL_/_Apache_configurations
[gzip]: http://www.djangoproject.com/documentation/middleware/#django-middleware-gzip-gzipmiddleware
[server-side caching]: http://www.djangoproject.com/documentation/cache/#the-per-site-cache
