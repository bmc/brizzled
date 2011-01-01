---
layout: article
title: Running a Ruby block as another user
tags: ruby, unix, processes
date: 2011-01-01
---

Recently, on [stack**overflow**][SO], someone asked:

> Can you execute a block of Ruby code as a different OS user?
> 
> What I, ideally, want is something like this:
> 
>     user("christoffer") do
>       # do something
>     end

My proposed solution, for Unix-like systems, turns out to be trivial and
seems worth blogging about. It makes use of:

* Ruby's block syntax, which allows a block of code (between `do` and `end`,
  or between curly brackets) to be passed, as an object, to a function.
* Ruby's [`etc` module][Ruby-etc] which, on Unix-like systems, allows
  access to the password database via familiar functions like `getpwnam`.
* Ruby's [`Process` module][Ruby-process], for forking a child process.

The function to run a block of Ruby code as another user is trivial:

<script src="https://gist.github.com/757519.js?file=asuser.rb"> </script>

Using the function is also trivial:

{% highlight ruby %}
    puts("Caller PID = #{Process.pid}")
    puts("Caller UID = #{Process.uid}")
    as_user "bmc" do |user|
      puts("In child process. User=#{user}, PID=#{Process.pid}, UID=#{Process.uid}")
    end
{% endhighlight %}

Of course, the calling code has to be running as *root* (or *setuid* to
*root*) to switch to another user. Running the above code on my Mac OS X
laptop yields this output:

    $ sudo ruby u.rb
    Caller PID = 98003
    Caller UID = 0
    In child process. User=bmc, PID=98004, UID=501

[SO]: http://stackoverflow.com/questions/4548151/run-ruby-block-as-specific-os-user/
[Ruby-etc]: http://ruby-doc.org/core-1.9/classes/Etc.html
[Ruby-process]: http://ruby-doc.org/core-1.9/classes/Process.html
