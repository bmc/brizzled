$! -*- mode: nxml; -*- !$

  <entry>
    <title>$article.title$</title>
    <link href="$page.baseURL$/id/$article.fileName$"/>
    <id>"$page.baseURL$/id/$article.fileName$"></id>
    <updated>$article.date; format="yyyy-MM-d'T'HH:mm:ssZ"$</updated>
    <content type="xhtml">
      <div xmlns="http://www.w3.org/1999/xhtml">$article.content$</div>
    </content>
    <summary type="xhtml">
      <div xmlns="http://www.w3.org/1999/xhtml">$article.description$</div>
    </summary>

    <author>
      <name>Brian M. Clapper</name>
      <email>bmc@clapper.org</email>
    </author>
  </entry>
