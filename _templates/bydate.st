<!-- -*- mode: html-helper; -*- -->
<span class="gutter-header">BY DATE</span>
<ul>
$page.recentDates:{ a | <li>$bydatelink(page=page, byDate=a)$$\n$</li>}$
</ul>

