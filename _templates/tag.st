$! -*- mode: html-helper; -*- !$
$htmlstart(page=page, custom=custom, tags=tags)$
$bodystart(page=page, custom=custom, tags=tags)$
$contentstart(page=page, custom=custom, tags=tags)$

<div id="articles-box">
<div id="articles-container">

<div class="article-title">
$page.tags.total$ article(s) tagged with "$page.tags.tagName$"
</div>

<div class="article-body">
<div>
<ul>
$page.tags.articles:{ a | <li>$articledatelink(article=a)$</li>$\n$}$
</ul>
</div>
</div>

</div>
</div>

$contentend(page=page, custom=custom, tags=tags)$
$bodyend(page=page, custom=custom, tags=tags)$
$htmlend(page=page, custom=custom, tags=tags)$
