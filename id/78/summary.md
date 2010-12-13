
I wrote blogging software that runs on [Google App Engine][] (GAE); this
blog is actually hosted at GAE. To increase performance, and reduce the
number of "you're using too much CPU" errors, I added a two-level page
cache to the blogging software. This article describes one way to add a
page cache to a blogging engine.

[Google App Engine]: http://appengine.google.com/
