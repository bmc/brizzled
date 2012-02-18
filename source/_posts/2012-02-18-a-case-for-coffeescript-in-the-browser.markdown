---
layout: post
title: "A Case for CoffeeScript in the Browser"
date: 2012-02-18 09:33
comments: true
categories: [javascript, coffeescript, jQuery]
---

Like many others who do some development for the web, I've grown to like
[CoffeeScript][]. The CoffeeScript package comes with a Javascript
implementation, allowing CoffeeScript to be translated into Javascript directly
in the browser. Jeremy Ashkenas, author of CoffeeScript, recommends against
using that approach for anything serious, and with good reason. However,
there's one scenario where I find CoffeeScript in the browser to be especially
useful.

<!-- more -->

I sometimes find myself writing new Javascript components, for use in software
I'm building. Often these components consist of custom [jQuery][] code that
must be tested in the browser. I find it easier to write, test, debug, and
demostrate those components in a standalone HTML document. Since I tend to
write those components in CoffeeScript lately, I need an easy way to translate
the CoffeeScript into Javascript.

Enter `coffee-script.js`.

Using CoffeeScript in the browser means I don't require back-end CoffeeScript-
to-Javascript translation while working on my code. For example, if I'm putting
together a custom [jQuery][] component, it's easier to code it all in a single
HTML document, without relying on a backend framework like [Rails][] to convert
the CoffeeScript for me. Using `coffee-script.js` also means I can package the
HTML document and its accompanying images, scripts, and stylesheets, in a Zip
file or tarball; I can send that package to someone else, and that person only
needs to unpack the package and point a browser at the `index.html` file to run
a demo.

The set up is easy enough. Here's an example. Suppose I'm building a new jQuery
UI component, for use in an application. While building and testing the
Javascript, I'll frame the CoffeeScript in a simple HTML document like this:

{% codeblock CoffeeScript Test File lang:html %}
<html>
<head>
<title>Widget test</title>
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js"></script>
</head>

<body>

<script type="text/coffeescript" src="widget.coffee"></script>

<h1 id="header" style="color: red">CoffeeScript test.</h1>
</body>

<!-- Pull coffee-script.js in AFTER all the CoffeeScript. -->
<script type="text/javascript" src="https://github.com/jashkenas/coffee-script/raw/master/extras/coffee-script.js"></script>
</html>
{% endcodeblock %}

It's important that the `<script>` tag for `coffee-script.js` occur _after_ the
actual CoffeeScript in the document. It will then find any `<script>` elements
with `type="text/coffeescript"`, convert them to Javascript, and run them.

If you prefer, of course, you can download copies of `jquery.min.js`,
`jquery.ui.js` and `coffee-script.js`, you can use local copies of the
Javascript files that are imported.

You can also put the CoffeeScript directly inline:
 
{% codeblock Embedded CoffeeScript lang:html %}
<script type="text/coffeescript">
$(document).ready ->
  alert "Better stuff will go here"
</script>
{% endcodeblock %}

I usually keep it in a separate file, though. It's easier to deploy that way,
when I'm done developing and testing it. Also, my editor will highlight the
syntax properly, if I store the actual source in a `.coffee` file.

For performance reasons, you don't want to deploy your code with CoffeeScript
in the browser. But, during development and testing, this technique can be
a useful timesaver.

[CoffeeScript]: http://coffeescript.org/
[CoffeeScript in the browser]: http://coffeescript.org/#scripts
[jQuery]: http://jquery.org/
[Rails]: http://www.rubyonrails.org/