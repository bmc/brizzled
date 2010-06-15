$! -*- mode: html-helper; -*- !$
<span class="gutter-header">BY DATE</span>
<ul>
$page.articlesByMonth:{ m | <li>$bymonthlink(page=page, byMonth=m)$$\n$</li>}$
</ul>

