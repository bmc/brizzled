---
layout: article
title: Finding Ruby Gem Specifications Programmatically
tags: ruby, rubygems, gems
date: 2011-03-27
---

So, you're writing a [Ruby Gem][] with a command-line program or two, and
you want to support a `--version` option. When that option is displayed,
obviously, your program will just emit the version and exit. Ideally, you
want to use the version number that's in the [Gem Specification][] file, so
you don't have put the version string in multiple places. Obviously, what
you want to do is find your gem's specification file at runtime, so you can
pull the data you want from it.

I had a surprisingly difficult time searching for the canonical way to
accomplish that task. I finally resorted to [UTSL][], at which point, all
became clear.

The solution is to use a `Gem::GemPathSearcher` class, an instance of which
is available via `Gem::searcher`:

    PROGRAM_NAME = 'coolness'
    THIS_GEM_PATH = 'coolness' # What you'd require to pull this thing in

    def show_version_only
      gem_spec = Gem.searcher.find(THIS_GEM_PATH)
      if not gem_spec
        raise StandardError.new("Can't find Gem specification for path \"" +
                                "#{THIS_GEM_PATH}\".")
      end
      puts("#{PROGRAM_NAME}, version #{gem_spec.version}. " +
           "#{gem_spec.homepage}")
    end

The `GemPathSearcher` class is documented
[here](http://rubygems.rubyforge.org/rubygems-update/Gem/GemPathSearcher.html).
Or, you can just [UTSL][].

[Ruby Gem]: https://rubygems.org/
[Gem Specification]: http://docs.rubygems.org/read/chapter/20
[UTSL]: http://www.catb.org/jargon/html/U/UTSL.html
