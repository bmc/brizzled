Source for my [Brizzled][] blog.  Must be formatted with [Jekyll][].

----

# Jekyll Hacks

## Escaping Liquid Tags

Courtesy of some monkeypatched hacks in `_plugins/page.rb`, [Liquid][]
tags can be escaped as follows:

    {\%   # yields {%
    \%}   # yields %}
    \{\{  # yields {{
    \}\}  # yields }}

## Table from YAML File

The `filetable` plug-in generates a table from a YAML file. The format of
the YAML file is:

    - topic: A topic, which will generate a <TH> row that spans all columns
      items: 
      # First item, which will have two cells:
      # 1. The blurb, which will link to the specified URL
      # 2. The description.
      - url: http://bmc.github.com/poll/
        blurb: "*poll*(2) emulator"
        description: Routine to emulate System V *poll*(2) function for BSD Unix systems

Multiple items are permitted within a topic, and multiple topics are permitted.
The tag looks like this:

    {% filetable yamlfile [options] %}

See `_plugins/filetable.rb` for the supported options.

## Tags

The `_plugins/tag.rb` and `_plugins/tags.rb` files generate pages for each
tag. The approach is adapted from <https://gist.github.com/524748>.

## Summary

Each page in the blog has a summary. `_plugins/summary.rb`, and some
monkeypatching in `_plugins/page.rb`, takes care of generating those
summary files.

## More Information

A description of many of the [Jekyll][] customizations is [here][105].

[Jekyll]: http://jekyllrb.com/
[Brizzled]: http://brizzled.clapper.org/
[Liquid]: http://www.liquidmarkup.org/
[105]: http://brizzled.clapper.org/id/105/
