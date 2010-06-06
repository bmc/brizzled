<!-- -*- mode: html-helper; -*- -->
$htmlstart(page=page, custom=custom, tags=tags)$
$bodystart(page=page, custom=custom, tags=tags)$

<div id="articles-box">
<div id="articles-container">

<div class="article-title">
$byMonth.total$ articles from date $byMonth.monthYear$
</div>

<div class="article-body">
<div id="by-date">
<ul>
$byMonth.articles:{ a | <li>$articledatelink(article=a)$</li>$\n$}$
</ul>
</div>
</div>

</div>
</div>

$bodyend(page=page, custom=custom, tags=tags)$
$htmlend(page=page, custom=custom, tags=tags)$
