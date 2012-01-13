require 'rubygems'
require 'maruku'
require 'fileutils'

module Jekyll

  # Deferred generator
  class AtomContent
    def initialize(html_file)
      @html_file = html_file
      @content = nil
    end

    def to_liquid
      @content ||= generate_atom  File.readlines(@html_file).join("")
    end

    def to_s
      "#{self.class.name}<#{@html_file}>"
    end

    def inspect
      self.to_s
    end

    def generate_atom(html)
      # Remove the leading content, up to just before the "articles-container"
      # <div>, and after the close of the <div> (which is marked).
      html.split("\n").drop_while do |line|
        # This will keep <body>, so the drop(1) that follows will have to
        # get rid of it.
        line !~ /^\s*<!-- #START ARTICLE/
      end.drop(1).take_while do |line|
        line !~ /^\s*<!-- #END ARTICLE/
      end.map do |line|
        line.strip
      end.select do |line|
        ! (line.empty? || line.include?('printer-friendly.html'))
      end.join("\n")
    end

  end
end
