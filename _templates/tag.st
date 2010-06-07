$! -*- mode: html-helper; -*- !$
$htmlstart(page=page, custom=custom, tags=tags)$
$bodystart(page=page, custom=custom, tags=tags)$
$contentstart(page=page, custom=custom, tags=tags)$

<div id="articles-box">
<div id="articles-container">

<div class="article-title">
$byTag.total$ article(s) tagged with "$byTag.tagName$"
</div>

<div class="article-body">
<div>
<ul>
$byTag.articles:{ a | <li>$articledatelink(article=a)$</li>$\n$}$
</ul>
</div>
</div>

</div>
</div>

$contentend(page=page, custom=custom, tags=tags)$
$bodyend(page=page, custom=custom, tags=tags)$
$htmlend(page=page, custom=custom, tags=tags)$
