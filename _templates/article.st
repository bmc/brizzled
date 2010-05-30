<!-- -*- mode: html-helper; -*- -->
$htmlstart(page=page, custom=custom, tags=tags)$
$bodystart(page=page, custom=custom, tags=tags)$

<!-- ARTICLE AREA -->

<div id="articles-box">
<div id="articles-container">

<div class="article">

<div class="article-header">

<div class="article-title">
<a href="$page.relativeRoot$/$page.fileName$" class="reference">$page.title$</a></div>

<div class="article-timestamp">$page.date; format="dd MMM, yyyy 'at' hh:mm a"$</div>
</div>

<script type="text/javascript" src="$page.relativeRoot$/cssjs/toc.js">
<!-- -->
</script>

<div class="article-body" id="content">

<div id="tocBlock">
<span id="tocHeading">Table of Contents</span>
<div id="toc"></div>
</div>

$page.content$
</div>

<br/><br/>

<div class="article-footer">
<a href="$page.relativeRoot$/$page.fileName$" class="reference">Permalink</a> |
<a href="$page.baseFileName$pr.html" class="reference">Printer-friendly</a> | 
<span class="tags">Tags: $page.tags; separator=", "$</span>
</div>

<!--
  .. disqus ..
-->
</div>

</div>
</div>

<script type="text/javascript">
createTOC();
</script>

$bodyend(page=page, custom=custom, tags=tags)$
$htmlend(page=page, custom=custom, tags=tags)$
