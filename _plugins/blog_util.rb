require 'kramdown'

module Jekyll

  module BlogUtil

    BRIZZLED_URL = "http://brizzled.clapper.org"

    def make_html(content)
      Kramdown::Document.new(content).to_html
    end

    def rfc3339_datetime(dt)
      dt.strftime('%Y-%m-%dT%H:%M:%S') + 'Z'
    end

    def rfc822_datetime(dt)
      dt.strftime('%a, %d %b %Y %T %z')
    end

  end
end
