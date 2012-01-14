module Jekyll

  module HTMLUtil

    def make_html(content)
      Maruku.new(content).to_html
    end
  end
end
