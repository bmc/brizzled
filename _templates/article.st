<!-- -*- mode: html-helper; -*- -->
$htmlstart(page=page, custom=custom, tags=tags)$
$bodystart(page=page, custom=custom, tags=tags)$

<script type="text/javascript" src="$page.relativeRoot$/cssjs/toc.js">
<!-- -->
</script>

<!-- ARTICLE AREA -->

<div id="articles-box">
<div id="articles-container">

<div class="article">

<div class="article-header">

<div class="article-title"><a href="$page.permalink$" class="reference">$page.title$</a></div>

<div class="article-timestamp">$page.date; format="dd MM, yyyy 'at' hh:mm a"$</div>
</div>

<div class="article-body">
$page.content$
</div>

<br/><br/>

<div class="article-footer">
<a href="$page.permalink$" class="reference">Permalink</a> |
<a href="printable-path" class="reference">Printer-friendly</a> | 
<span class="tags">Tags: $page.tags; separator=", "$</span>
</div>

<!--
  .. disqus ..
-->
</div>


</div>
</div>

  <!-- TAGS -->

<div id="tags-box">
$page.allTags:tagcloudlink(); separator=", "$
</div>

$bodyend(page=page, custom=custom, tags=tags)$
$htmlend(page=page, custom=custom, tags=tags)$
