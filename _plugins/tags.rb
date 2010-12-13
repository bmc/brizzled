# Adapted from https://gist.github.com/524748

module Jekyll

  # A version of a page that represents a tag index.

  class TagIndex < Page
    def initialize(site, base, dir, tag, articles)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'
      self.process(@name)
      tag_index = (site.config['tag_index_layout'] || 'tag_index') + '.html'
      self.read_yaml(File.join(base, '_layouts'), tag_index)
      self.data['tag'] = tag
      self.data['articles'] = articles.sort { |p1, p2| p1.date <=> p2.date }
      tag_title_prefix = site.config['tag_title_prefix'] || 'Tag: '
      self.data['title'] = "#{tag_title_prefix}#{tag}"
      @summary = Summary.empty
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
