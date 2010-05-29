<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">

<!-- Default layout file for Corgi -->

<html>
<head>
<link href="$page.baseURL$/css/style.css" media="screen" rel="stylesheet" type="tex/css"/>
<title>$custom.blogname$: Articles tagged with $tag.name$</title>
</head>

<body>
<h1>$tag.total$ articles tagged with "$tag.name$"</h1>

<div id="tag-cloud">

$tag.articles:{ a | <li>$articlelink(article=a)$</li>
}$
</ul>
</div>

</body>
</html>
