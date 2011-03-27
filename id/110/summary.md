So, you're writing a [Ruby Gem][] with a command-line program or two, and
you want to support a `--version` option. When that option is displayed,
obviously, your program will just emit the version and exit. Ideally, you
want to use the version number that's in the [Gem Specification][] file, so
you don't have put the version string in multiple places. So, you have to
find your gem's specification file at runtime and pull the data you want
from it.

But, how?

[Ruby Gem]: https://rubygems.org/
[Gem Specification]: http://docs.rubygems.org/read/chapter/20
