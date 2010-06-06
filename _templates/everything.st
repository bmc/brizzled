$! -*- mode: html-helper; -*- !$
$htmlstart(page=page, custom=custom, tags=tags)$
$bodystart(page=page, custom=custom, tags=tags)$

<!-- ARTICLE AREA -->

<div id="articles-box"> 
<div id="articles-container"> 
 
<div id="content" class="article-body">

$trunc(page.articles):{ a | $indexArticle(article=a)$$\n$<hr/>}$
$last(page.articles):{ a | $indexArticle(article=a)$$\n$}$

</div>
</div>
</div>

$bodyend(page=page, custom=custom, tags=tags)$
$htmlend(page=page, custom=custom, tags=tags)$
