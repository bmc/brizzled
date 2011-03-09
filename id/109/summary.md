Recently, I decided I wanted to customize the output of a [Rake][] run so
that the various messages emitting during Rake's processing were preceded
by a timestamp. In addition, I wanted a simple function that would write a
message to standard output or error, if `rake` had been invoked with the
`-v` (verbose) command line option.

I figured these goals should be easily satisfied, but, as it happens,
solving both problems was less trivial than I expected. Via Ruby's support
for [metaprogramming][], though, I managed to hack together a solution.


[Rake]: http://rake.rubyforge.org/
[metaprogramming]: http://practicalruby.blogspot.com/2007/02/ruby-metaprogramming-introduction.html
