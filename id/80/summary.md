
Google [App Engine][] (GAE) is a useful platform on which to develop
Python-based web applications. But a GAE application runs in a [sandbox][]
that prevents it from opening a socket, which makes the standard Python
`xmlrpclib` module inoperable.

Fortunately, there's a simple solution to this problem.

[App Engine]: http://appengine.google.com/
[sandbox]: http://code.google.com/appengine/docs/python/sandbox.html
