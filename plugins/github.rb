# Plugin to embed a GitHub commit inline. Akin to the Gist plugin,
# conceptually. Uses the Octokit GitHub API
# (https://github.com/pengwynn/octokit).
#
# The content of the commit is downloaded at the time the blog is generated.
# It is not cached anywhere (other than inline, in the generated HTML).
#
# USAGE:
#
#   {% github user/repo commit_hash %}
#
# Get a file's commit hash as follows:
#
#   $ git hash-object path-to-file
#
# If it's code, you might want to put it inside a codeblock.
#
# Example:
#
#   {% codeblock lang:ruby %}
#     {% github bmc/brizzled e075222a56ea062d33be86e410f98f252e72b3fd %}
#   {% endcodeblock %}
#
# Copyright (c) 2012 Brian M. Clapper <bmc@clapper.org>
#
# Released under a standard BSD license.

require 'rubygems'
require 'octokit'
require 'base64'

module Jekyll

  class GitHub < Liquid::Tag
    include TemplateWrapper

    def initialize(tag_name, markup, tokens)
      args = markup.strip.split(/\s+/, 3)
      raise "Usage: #{tag_name} user/repo file_hash" unless args.length == 2
      @repo = args[0]
      @hash = args[1]
      super
    end

    def render(context)
      gh = Octokit::Client.new
      obj = gh.blob(@repo, @hash)
      Base64.decode64(obj.content)
    end

  end

end

Liquid::Template.register_tag("github", Jekyll::GitHub)
