---
layout: article
title: 'Customizing Rake messages: Is there an easier way?'
tags: ruby, rake, programming
date: 2011-03-09 00:00:00
toc: toc
---

# Intro

Recently, I decided I wanted to customize the output of a [Rake][] run so
that the various messages emitting during Rake's processing were preceded
by a timestamp, something like this:

    [08:32:02.013] cc -c foo.c -Iinclude
    [08:32:02.821] cc -o foo foo.o -Llib

In addition, I wanted a simple function that would write a message to
standard output or error, if `rake` had been invoked with the `-v` (verbose)
command line option.

I figured these goals should be easily satisfied.

* Rake already emits some messages only if `-v` is specified, so I assumed
  a function already existed that I could use; I'd merely have to find it.
* The Rakefile is, essentially, an instance of a `Rake::Application` object
  and has access to much of the Rake runtime, so it should be able to customize
  whatever message format is used to emit Rake messages.

As it happens, solving both problems was less trivial than I expected. I
did come up with a solution, but it's brittle and likely to break if
subsequent versions of Rake change how things are done under the covers.

Perhaps someone else out there has solved these problems more elegantly.

# Hacking Rake's Output Messages

To solve this problem, I had to do a little [metaprogramming][]. I located
two places where Rake emits messages. The first is via the [FileUtils][]
module, which Rake augments. Digging through the code, I noticed that
FileUtils supports a label that can be set to a prefix to use for output
messages. So, it's possible to patch FileUtils, like so:

{% highlight ruby %}
module FileUtils
  alias :real_fu_output_message :fu_output_message
  def fu_output_message(msg)
    @fileutils_label = Time.now.strftime('[%H:%M:%S] ')
    real_fu_output_message msg
  end
end
{% endhighlight %}

The other method that needs to be patched is Rake's `rake_output_message`
function:

{% highlight ruby %}
alias :real_rake_output_message :rake_output_message
def rake_output_message(message)
  real_rake_output_message Time.now.strftime('[%H:%M:%S] ') + message
end
{% endhighlight %}

# Emitting Verbose Messages

I thought Rake might have a method that one could call to emit messages
only if `-v` had been specified, akin to the way logging frameworks work.
I couldn't find one, however, so I simply wrote my own:

{% highlight ruby %}
def vmessage(message)
  if RakeFileUtils.verbose_flag == true
    rake_output_message message
  end
end
{% endhighlight %}

This function, in combination with the metaprogramming, above, allows me to
write tasks like this:

{% highlight ruby %}
file 'prog' => ['prog.o', 'lib.o'] do |t|
  vmessage "Making #{t.name}"
  sh "cc -o prog prog.o lib.o"
end
{% endhighlight %}

# Putting It All Together

I elected to put this hack in a [gem][], which consolidates the timestamp
stuff into one place, like so:

{% highlight ruby %}
require 'rake'

module GrizzledRake
  module TimeFormat
    # Set the strftime format for output message. Use '$m' in the format,
    # if you want milliseconds. A trailing blank is automatically added.
    @@timestamp_format = nil
    def timestamp_format=(format)
      @@timestamp_format = format
    end

    def s_now
      if @@timestamp_format
        now = Time.now
        ms = (now.usec / 1000).to_s
        fmt = @@timestamp_format
        now.strftime(fmt).sub('$m', ms) + ' '
      else
        ''
      end
    end
  end
end

include GrizzledRake::TimeFormat

# Force output from FileUtils to have a timestamp prefix.
module FileUtils
  include GrizzledRake::TimeFormat

  alias :real_fu_output_message :fu_output_message
  def fu_output_message(msg)
    @fileutils_label = s_now
    real_fu_output_message msg
  end
end

# Ditto for output from Rake itself.
alias :real_rake_output_message :rake_output_message
def rake_output_message(message)
  real_rake_output_message s_now + message
end

def vmessage(message)
  if RakeFileUtils.verbose_flag == true
    rake_output_message message
  end
end
{% endhighlight %}

The `GrizzledRake::TimeFormat` module simply consolidates the timeformat
handling in one place.

Once the gem is installed, two lines of code in my Rakefile will enable
timestamps:

{% highlight ruby %}
require 'grizzled/rake'

# Set strftime format to use for timestamps. If this isn't set, then
# no timestamps are used (i.e., Rake messages look "normal").
GrizzledRake::TimeFormat::timestamp_format = '[%H:%M:%S.$m]'
{% endhighlight %}

Note that I extended the *strftime* escapes to support a `$m` escape, allowing
the insertion of milliseconds into the output. *strftime* does not support
that capability.

## Conclusion

This works, but it's a complete hack, and it's brittle: If the innards of
`FileUtils` or Rake change, this approach might break, without warning.

Ideally, Rake's API would provide a clean way to accomplish these goals,
without this kind of hacking. Until it does, though, [metaprogramming][]
for the win.

[gem]: https://github.com/bmc/grizzled-rake
[Rake]: http://rake.rubyforge.org/
[metaprogramming]: http://practicalruby.blogspot.com/2007/02/ruby-metaprogramming-introduction.html
[FileUtils]: http://www.ruby-doc.org/stdlib/libdoc/fileutils/rdoc/classes/FileUtils.html
[gem]: http://rubygems.org/
