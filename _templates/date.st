<!-- -*- mode: html-helper; -*- -->
$htmlstart(page=page, custom=custom, tags=tags)$
$bodystart(page=page, custom=custom, tags=tags)$

<div id="articles-box">
<div id="articles-container">

<div class="article-title">
$byDate.total$ articles from date $byDate.date$
</div>

<div class="article-body">
<div id="by-date">
<ul>
$byDate.articles:{ a | <li>$articledatelink(article=a)$</li>$\n$}$
</ul>
</div>
</div>

</div>
</div>

$bodyend(page=page, custom=custom, tags=tags)$
$htmlend(page=page, custom=custom, tags=tags)$
