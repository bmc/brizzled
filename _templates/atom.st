$! -*- mode: nxml; -*- !$

<feed xmlns="http://www.w3.org/2005/Atom">

  <title>$custom.blogname$: Brian Clapper's Blog</title>
  <link href="$custom.blogurl$"/>
  <updated>$page.lastUpdated; format="yyyy-MM-d'T'HH:mm:ssZ"$</updated>
  <author>
    <name>Brian M. Clapper</name>
    <email>bmc@clapper.org</email>
  </author>
  <id>$custom.blogURL$</id>
  $page.allArticles:{ a | $atomentry(article=a, page=page)$}$
</feed>
