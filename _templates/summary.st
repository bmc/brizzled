<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">

<!-- Default layout file for Corgi -->

<html>
<head>
<link href="$page.baseURL$/css/style.css" media="screen" rel="stylesheet" type="tex/css"/>
<title>$custom.blogname$: $if (page.title)$$page.title$$endif$</title>
</head>

<body>
<h1>$if (page.title)$$page.title$$endif$</h1>

<div id="content">
$page.content$

<ul>
$page.articles:{ a | <li>$articlelink(article=a)$$\n$</li>}$
</ul>
</div>

<p>By tag:</p>

<ul>
$page.tags:{ tag | <li>$tag.name$ ($tag.total$)$\n$<ul>$\n$$tag.articles:{ a | <li>$a.title$</li>$\n$}$</ul>$\n$</li>$\n$}$
</ul>



<div id="tags">Tags: $page.tags; separator=", "$</div>

<div id="date">Last modified: $page.date; format="yyyy-MM-dd"$</div>
<div id="date">Another way to say it: $page.date$</div>
<div id="permalink">Permalink: <a href="$page.permalink$">$page.permalink$</a></div>
</body>
</html>
