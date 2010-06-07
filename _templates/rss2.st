$! -*- mode: nxml; -*- !$
<?xml version="1.0" encoding="utf-8" ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
  <channel>
    <title>$custom.blogname$: Brian Clapper's Blog</title>
    <link href="$custom.blogurl$"/>
    <description>Brian Clapper's blog</description>
    <pubDate>$page.lastUpdated; format="MMM, d MM yyy HH:mm:ss Z"$</pubDate>
    $page.articles:{ a | $rss2item(article=a, page=page)$}$
  </channel>
</rss>
