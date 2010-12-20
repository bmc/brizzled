require 'delegate'

module Jekyll
    class PrintablePage < DelegateClass(Page)

        def initialize(page)
            @real_page = page
            @dir = page.dir
            @base = page.base
            @name = page.name
            @site = page.site

            super(@real_page)
            self.data = @real_page.data.clone
            self.data['layout'] = 'printable_article'
        end

        def render(layouts, site_payload)
            @real_page.render(layouts, site_payload)
        end

        # Hack
        def write(dest_prefix, dest_suffix = nil)
            dest = File.join(dest_prefix, @real_page.dir)
            dest = File.join(dest, dest_suffix) if dest_suffix

            # The url needs to be unescaped in order to preserve the
            # correct filename

            path = File.join(dest, CGI.unescape(self.full_url))
            if self.url =~ /\/$/
                FileUtils.mkdir_p(path)
                path = File.join(path, "printable.html")
            end

            path.sub!('index.html', 'printable.html')
            File.open(path, 'w') do |f|
                f.write(self.output)
            end
        end
    end 
end
