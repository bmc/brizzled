---
layout: post
comments: true
title: "How Not to Design a Database"
date: 2010-02-03 00:00
categories: [rdbms, microsoft, access, database]
---

How not to build a database:

1. Create a schema, and fill it with useful data.
2. As needs grow, and you have to consume slightly different kinds
   of data, don't fix the schema; instead, clone the original schema,
   and hack the clone to fit the new data.
3. Repeat step 2 at least 30 times.

I'm often surprised how poorly structured corporate production
databases can be. It's clear, in hindsight, that such databases
weren't planned. They grew in the same way that many American
suburbs grow: in fits and starts, driven by the need for revenue
and profit, with minimal technical oversight.

Many people in corporate America seem to be designing data
solutions without even a rudimentary understanding of database
design, using tools like Microsoft Access (or PHP and MySQL).

The easy availability of simple database tools is not always a good
thing. Microsoft Access, in the hands of some folks, is like a
pistol in the hands of a 6-year-old: You can explain the principles
of safe use over and over again, but there's still a strong
likelihood the kid's going to shoot himself in the foot.

