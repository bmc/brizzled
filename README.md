Source for my [Brizzled][] blog.  Must be formatted with [Jekyll][].

## Notes

* Courtesy of some monkeypatched hacks in `_plugins/page.rb`, [Liquid][]
  tags can be escaped as follows:

    {\%   # yields {%
    \%}   # yields %}
    \{\{  # yields {{
    \}\}  # yields }}

* A description of the local, plugin-driven [Jekyll][] customizations is
  [here][105].

[Jekyll]: http://jekyllrb.com/
[Brizzled]: http://brizzled.clapper.org/
[Liquid]: http://www.liquidmarkup.org/
[105]: http://brizzled.clapper.org/id/105/
