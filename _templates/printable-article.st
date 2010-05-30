<!-- -*- mode: html-helper; -*- -->

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>$custom.blogname$: $if (page.title)$$page.title$$endif$</title>
<link href="$page.relativeRoot$/cssjs/style-printable.css" media="screen" rel="stylesheet" type="text/css"/>
<link href="$page.relativeRoot$/cssjs/common.css" media="screen" rel="stylesheet" type="text/css"/>
</head>

<body>

<!-- ARTICLE AREA -->

<div class="printable-page">

  <h1>$custom.blogname$: $if (page.title)$$page.title$$endif$</h1>

  <p>Brian M. Clapper, <i>bmc@clapper.org</i></p>

  <p><b>Published on</b>: $page.date; format="dd MMM, yyyy 'at' hh:mm a"$<br/>
  <b>Tags</b>: $page.tags; separator=", "$</p>

  <script type="text/javascript" src="$page.relativeRoot$/cssjs/toc.js">
  <!-- -->
  </script>

  <div id="content">

    <div id="tocBlock">
      <span id="tocHeading">Table of Contents</span>
      <div id="toc"></div>
    </div>

$page.content$
  </div>
</div>

<script type="text/javascript">
createTOC();
</script>

</body>
</html>
