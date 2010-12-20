require 'date'

module Jekyll

    # Extensions to the Jekyll Page class.

    class Page

        BRIZZLED_URL = "http://brizzled.clapper.org"
        SUMMARY_FILE = "summary.md"
        SUMMARY_HTML = "summary.html"

        # Additional accessors

        attr_accessor :base, :markdown, :summary

        # Chained version of constructor, used to generate the location of
        # the "summary" file.
        alias orig_init initialize
        def initialize(site, base, dir, name)
            orig_init(site, base, dir, name)

            # Allow for a summary.md file that generates the article summary.
            @summary = Summary.new(File.join(@base, @dir, SUMMARY_FILE),
                                   File.join(@base, site.dest, @dir, 
                                             SUMMARY_HTML))
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

            if @summary
                h['summary'] = @summary
                h['has_summary'] = @summary.has_summary?
            else
                h['has_summary'] = false
            end

            h['path'] = File.join(@base, @dir, @name)
            h['now'] = Date.today
            h['tags'] = Tag.sort(tags)
            h['max_top'] = (self.data['max_top'] ||
                            site.config['max_top'] ||
                            15)
            h
        end

        # Chained version of render() method. This version takes the
        # output (from `self.output`) and "fixes" escaped Liquid
        # strings, allowing Liquid markup to be escaped, for display.
        alias orig_render render
        def render(layouts, site_payload)
            res = orig_render(layouts, site_payload)
            self.output = fix_liquid_escapes(self.output)
            res
        end

        # Get the list of tags, unsorted. Returned array consists of Tag
        # objects.
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

        def fix_liquid_escapes(s)
            s.gsub!('\{\{', '{{')
            s.gsub!('\}\}', '}}')
            s.gsub!('\%', '%')
            s.gsub!("\\\\", "\\")
            s
        end
    end
end
