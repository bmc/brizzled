<!-- -*- mode: html-helper; -*- -->
<span class="gutter-header">BY DATE</span>
<ul>
$page.recentMonths:{ m | <li>$bymonthlink(page=page, byMonth=m)$$\n$</li>}$
</ul>

