# Include a file inline, from anywhere. Supports variable substitution,
# as well. This plugin sort of combines the Octopress render_partial and
# include_code plugins, but allows inclusion outside the blogging application.
#
# Syntax:
#
#    {% include_file /path/to/file %}
#
# The path is expected to be a full path. The following variables may be used,
# as well:
#
# ${BLOG_SOURCE} - The path to the source directory
# ${BLOG_ROOT}   - The top of the Octopress directory
#
# Example: Include file "foo.rb" from the plugins directory:
#
#    {% include_file ${BLOG_ROOT}/plugins/foo.rb %}

require './plugins/raw'
require 'pathname'
require 'grizzled/string/template'

module Jekyll

  class IncludeFileTag < Liquid::Tag
    include Grizzled::String::Template
    include TemplateWrapper

    def initialize(tag_name, markup, tokens)
      @path = markup.strip
      super
    end

    def render(context)
      source = Pathname.new(context.registers[:site].source)
      vars = {
        "BLOG_SOURCE" => source.to_s,
        "BLOG_ROOT"   => source.dirname.to_s
      }
      template = UnixShellStringTemplate.new(vars, :safe => false)
      path = Pathname.new(template.substitute(@path))
      return "File #{path} could not be found." unless path.file?

      path.read
    end
  end

end

Liquid::Template.register_tag('include_file', Jekyll::IncludeFileTag)
