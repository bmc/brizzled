$! -*- mode: html-helper; -*- !$

<a href="$page.baseFileName$.html#disqus_thread">Comments</a>
<div id="disqus_thread"></div>

<script type="text/javascript">
  // Use the base file name (without the ".html") as the Disqus URL. This is
  // necessary to be consistent with old version of Brizzled on App Engine.
  $if (page.disqusID)$
  var disqus_identifier = "$page.disqusID$";
  var disqus_url = "$page.disqusID$";
  $else$
  var disqus_identifier = "$page.baseURL$id/$page.baseFileName$";
  var disqus_url = "$page.baseURL$id/$page.baseFileName$";
  $endif$
  var disqus_title = "$custom.blogname$: $page.title$";

  $if (page.disqus_developer)$
  var disqus_developer = 1;
  $endif$

  (function() {
   var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
   dsq.src = 'http://brizzled.disqus.com/embed.js';
   (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
  })();

</script>

<noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript=brizzled">comments powered by Disqus.</a></noscript>
<a href="http://disqus.com" class="dsq-brlink">blog comments powered by <span class="logo-disqus">Disqus</span></a>

