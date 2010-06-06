$! -*- mode: html-helper; -*- !$
<div class="article">
  <div class="article-header">
    <div class="article-title">
      <a href="$article.permalink$" class="reference">$article.title$</a>
    </div>
    <div class="article-timestamp">
      $article.date; format="dd MMM, yyyy 'at' hh:mm a"$
    </div>
  </div>

  <div class="article-description">$article.description$</div>

  <div class="article-footer">
    <a href="$article.permalink$" class="reference">Read the entire article.</a>
    <span class="tags">Tags: $article.tags; separator=", "$</span>
  </div>
</div>
