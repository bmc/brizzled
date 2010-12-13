require 'date'

module Jekyll

  # Extensions to the Jekyll Page class.

  class Page

    BRIZZLED_URL = "http://brizzled.clapper.org"
    SUMMARY_FILE = "summary.md"
    SUMMARY_HTML = "summary.html"

    @_tags = nil

    # Add some custom options to the site payload, accessible via the
    # "page" variable within templates.
    alias orig_init initialize
    def initialize(site, base, dir, name)
      orig_init(site, base, dir, name)
      @summary = Summary.new(File.join(@base, @dir, SUMMARY_FILE),
                             File.join(@base, site.dest, @dir, SUMMARY_HTML))
    end

    # Add some custom options to the Liquid data for the page.
    #
    # toc              - set to "yes" if the "toc" variable is set, "no" if
    #                    not. From the YAML header.
    # disqus_id        - page ID to use for Disqus. Can be set in the YAML
    #                    header.
    # disqus_developer - Whether or not 'disqus_developer' should be set.
    #                    From the YAML header.
    # date             - Date for the page, from the YAML header. Defaults
    #                    to current date.
    # summary          - Rendered content of the summary, or nil for none.
    # has_summary      - true if a summary exists, false if not.
    # path             - full path to the page input file
    # now              - current time
    # tags             - page's tags, sorted by name, as Tag objects.
    alias orig_to_liquid to_liquid
    def to_liquid
      h = orig_to_liquid
      h['toc'] = self.data['toc'] || 'no'
      h['disqus_id'] = self.data['disqus_id'] || "#{BRIZZLED_URL}#{@dir}/"
      h['disqus_developer'] = self.data['disqus_developer'] || nil
      h['date'] = self.date
      h['summary'] = @summary
      h['has_summary'] = @summary.has_summary?
      h['path'] = File.join(@base, @dir, @name)
      h['now'] = Date.today
      h['tags'] = Tag.sort(tags)
      h
    end

    # Get the list of tags, unsorted. Returned array consists of Tag objects.
    def tags
      (self.data['tags'] || "").split(',').map {|t| Tag.new(t)}
    end

    # Full URL of the page.
    def full_url
      File.join(@dir, self.url)
    end

    # Page date, from the YAML header, or current date.
    def date
      self.data['date'] || Date.today
    end

  end

end
