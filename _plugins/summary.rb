require 'rubygems'
require File.join(File.dirname(__FILE__), 'blog_util.rb')
require 'fileutils'

module Jekyll

  class Summary

    include Jekyll::BlogUtil

    @@EMPTY = nil

    def self.empty
      if @@EMPTY.nil? then
        @@EMPTY = Summary.new("", "")
      end
      @@EMPTY
    end

    def initialize(source_file, html_file)
      @summary_file = source_file
      @summary_html = html_file
    end

    def to_liquid
      File.exists?(@summary_file) ? get_html : ""
    end

    def has_summary?
      File.exists?(@summary_file)
    end

    def inspect
      @summary_file
    end

    def to_s
      inspect
    end

    private

    def get_html
      summary_dir = 
      if not File.exists?(@summary_html)
        #puts("#{@summary_html} does not exist. Making it.")
        html = write_summary_html(make_html(read_summary))
      elsif (File.mtime(@summary_html) <=> File.mtime(@summary_file)) < 0
        puts("#{@summary_html} is older than #{@summary_file}. Remaking.")
        html = write_summary_html(make_html(read_summary))
      else
        html = File.readlines(@summary_html).join("")
      end

      html
    end

    def read_summary
      File.readlines(@summary_file).join("")
    end

    def write_summary_html(html)
      FileUtils.mkdir_p File.dirname(@summary_html)
      File.open(@summary_html, 'w') do |f|
        f.write(html)
      end
      html
    end
  end
end
