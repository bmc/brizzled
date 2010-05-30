<!-- -*- mode: html-helper; -*- -->
<body>

<!-- BANNER -->

<div class="banner-background">
  <div class="banner">

    <div class="banner-image">
    <a href="$page.relativeRoot$/id/4"><img src="$page.relativeRoot$/images/brizzled.png" width="341" height="56" border="0" align="left"/></a>
    </div>

    <div class="banner-tagline">It'll only sting a little</div>

    <div class="banner-nav">
      <div class="text-button" style="width: 7em"><a href="$custom.blogPath$">top</a></div>
      <div class="text-button" style="width: 7em"><a href="$tags.dir$/everything.html">everything</a></div>
    </div>
  </div>
</div>

<!-- GUTTER -->

<div class="gutter">
  <div class="gutter-item"></div>

  <div class="gutter-item">
    <a href="$page.relativeRoot$/images/about-me.html" rel="lyteframe" title="Brian M. Clapper" rev="">
    <img border="0" src="$page.relativeRoot$/images/bmc-head-shot-2009.jpg" width="80" height="91" align="left">
    </a>
  </div>
  
  <div class="gutter-item">
    <div class="email">bmc&nbsp;@&nbsp;clapper.org</div>
  </div>

  <div class="gutter-item">
    <div class="text-button">
      <a href="$page.relativeRoot$/about-me.html" rel="lyteframe" title="Brian M. Clapper"
         rev="" class="button">About me</a>
    </div>
  </div>

  <div class="gutter-item">
    <a title="Summary Atom feed" href="$page.relativeRoot$/atom-summary.xml" class="button"><img src="$page.relativeRoot$/images/atom-small.gif" width="32" height="15" border="0" align="left">&nbsp;(summary)</a>
  </div>

  <div class="gutter-item">
    <a title="Full-content Atom feed" href="$page.relativeRoot$/atom-full.xml" class="button"><img src="$page.relativeRoot$/images/atom-small.gif" width="32" height="15" border="0" align="left">&nbsp;(full)</a>
  </div>

  <div class="gutter-item">
    <a title="Summary RSS-2 feed" href="$page.relativeRoot$/rss-summary.xml" class="button"><img src="$page.relativeRoot$/images/rss2-small.gif" width="49" height="15" border="0">&nbsp;(summary)</a>
  </div>

  <div class="gutter-item">
    <a title="Full-content RSS-2 feed" href="$page.relativeRoot$/rss-full.xml" class="button"><img src="$page.relativeRoot$/images/rss2-small.gif" width="49" height="15" border="0">&nbsp;(full)</a>
  </div>

  <div class="gutter-item">
    $if (page.recentArticles)$$recent(page=page)$$endif$
  </div>
  <div class="gutter-item">
    $if (page.recentDates)$$bydate(page=page)$$endif$
  </div>

</div>

<div id="content-box"> <!-- closed in footer.st -->
