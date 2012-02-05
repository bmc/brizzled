# bmc@clapper.org

module CodeFigure
  def figurize(str, title)
    res  = "<figure class='code'>"
    res += "<figcaption><span>#{@title}</span></figcaption>" if @title
    res += str
    res += "</figure>"
  end
end
