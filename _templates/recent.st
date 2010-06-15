$! -*- mode: html-helper; -*- !$
<span class="gutter-header">RECENT</span>
<ul>
$page.recentArticles:{ a | <li>$articlelink(page=page, article=a)$$\n$</li>}$
</ul>

