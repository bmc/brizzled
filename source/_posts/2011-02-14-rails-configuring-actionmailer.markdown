---
layout: post
comments: false
title: "Rails: Configuring ActionMailer"
date: 2011-02-14 00:00
categories: [ruby, email, mail, rails, programming]
---

# The problem

In a collaborative [Rails][] development effort, we use [AuthLogic][] for
authentication, providing the typical [email activation][] capability that
pretty much everyone on the web uses these days. By default, the email is
routed through my client's email service. For local testing, though, I'd
rather just route those emails through my in-home local SMTP server. It's
faster, it's totally contained within my LAN, and it bypasses my main email
server's [greylisting][].

Ideally, I want:

* the default email configuration to be set in the `config/environment.rb`
  file; and
* the ability, in my own configuration, to override those settings.

# A simple solution

One simple solution I came up with follows.

First, in `config/environment.rb`, I define various globals, which I then
use to configure ActionMailer:

{% gist 826322 %}

In my environment, I have `RAILS_ENV` set to `bmc-dev`. So, I have my
configuration overrides in `config/bmc-dev.rb`. In that file, I simply
include:

{% gist 826333 %}

As a result, when testing within my home LAN, emails from Rails go to my
inside-the-LAN email server.

# Caveats

* These comments are valid for Rails 2. Things are different in Rails 3,
  I'm told. When I get the chance to test against Rails 3, I'll update this
  page.
* I'm sure a [Rails][] guru can suggest a better means of solving this problem;
  in fact, I'm hoping someone does and shares it with me.

[Rails]: http://www.rubyonrails.org/
[AuthLogic]: https://github.com/binarylogic/authlogic
[email activation]: https://github.com/matthooks/authlogic-activation-tutorial
[greylisting]: http://greylisting.org/
