# Adapted from https://gist.github.com/524748

require 'fileutils'

module Jekyll

  # A version of a page that represents a tag index.

  class TagIndex < Page
    attr_reader :dir
    def initialize(site, base, dir, tag, articles)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'
      self.process(@name)
      tag_index = (site.config['tag_index_layout'] || 'tag_index') + '.html'
      self.read_yaml(File.join(base, '_layouts'), tag_index)
      self.data['tag'] = tag
      self.data['articles'] = articles.sort { |p1, p2| p2.date <=> p1.date }
      tag_title_prefix = site.config['tag_title_prefix'] || 'Tag: '
      self.data['title'] = "#{tag_title_prefix}#{tag}"
      @summary = Summary.empty
    end

    def render(layouts, site_payload)
      begin
        res = super(layouts, site_payload)
        tag_dir = File.join(self.base, self.dir)
        FileUtils::mkdir_p tag_dir
        path = File.join(tag_dir, self.name)
        open(path, "w") do |f|
          f.write(self.output)
        end
        res
      rescue
        puts("Error during processing of #{self.full_url}")
        raise
      end
    end
  end

  class TagGenerator < Generator
    safe true
    
    def generate(site)
      if site.layouts.key? 'tag_index'
        dir = site.config['tag_dir'] || 'tags'
        tags = site.pages_by_tag
        tags.keys.sort {|k1, k2| k1 <=> k2}.each do |tag|
          write_tag_index(site, File.join(dir, tag.dir), tag,
                          tags[tag].to_a.sort {|t1, t2| t1.name <=> t2.name})
        end
      end
    end
  
    def write_tag_index(site, dir, tag, articles)
      index = TagIndex.new(site, site.source, dir, tag, articles)
      index.render(site.layouts, site.site_payload)
      index.write(site.dest)
    end
  end
end
