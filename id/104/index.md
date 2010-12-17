---
layout: article
title: Getting Delicious bookmarks to Diigo
tags: del.icio.us, diigo, bookmarks
date: 2010-12-17
---

On 16 December, 2010, a [leaked slide][], purportedly from [Yahoo!][]
all-hands meeting, seemed to indicate that Yahoo! was planning to shut
down its popular [Delicious][] bookmarking site. Yahoo [denies the rumor][],
but does state that Delicious is not a "strategic fit at Yahoo!".

[leaked slide]: http://mashable.com/2010/12/16/leaked-slide-shows-yahoo-is-killing-delicious-other-web-apps/
[Yahoo!]: http://www.yahoo.com/
[Delicious]: http://www.delicious.com/
[denies the rumor]: http://mashable.com/2010/12/17/state-of-delicious/

Loads of people are now looking for alternatives to Delicious. I have
settled on [Diigo][], for these reasons:

* It has a extension for [Google Chrome][], the browser I use most these days,
  as well as a Firefox extension.
* It has an [API][Diigo API], though the API is not very well documented.
* It supports essentially the same features as Delicious, with additional
  capabilities.
* It has both a free and a premium service.

[Diigo]: http://www.diigo.com/
[Google Chrome]: http://www.google.com/chrome/
[Diigo API]: http://www.diigo.com/tools/api

The trick, of course, is getting my Delicious bookmarks *into* Diigo. Diigo
has a web-based service for importing one's Delicious bookmarks, but it
hasn't worked for me so far. It turns out, however, that it's not difficult
to hack together a quick program to do it manually. Starting with the
[diigo.py][] file at [slumpy.org](http://slumpy.org), I hacked together a
quick Python script, [delicious2diigo.py][].

[diigo.py]: http://slumpy.org/files/diigo.py_.txt
[delicious2diigo.py]: delicious2diigo.py

To use it, download the script and save it. Then, edit the credential
constants at the top of the file to correspond to your Delicious and Diigo
login credentials.

If you call it with no arguments:

{% highlight bash %}
    $ python delicious2diigo
{% endhighlight %}

it will attempt to download your Delicious bookmarks (as XML), parse them,
and upload them to Diigo.

However, if you have already downloaded your Delicious bookmarks as XML,
you can simply pass the XML file directly to the script:

{% highlight bash %}
    $ python delicious2diigo bookmarks.xml
{% endhighlight %}

The script can take awhile to run, if you have a lot of bookmarks. Diigo's
API apparently accepts up to 100 bookmarks at a time, so the script breaks
your bookmarks into chunks of 100. I noticed that Diigo's API web site
occasionally throws HTTP 503 errors (perhaps because it's overloaded), so
the script retries an upload if it receives that error.

I used the script to upload several hundred Delicious bookmarks, and it
worked fine for me, preserving the bookmarks' titles, URLs and tags. Your
mileage, of course, may vary.

You can download the script [here][delicious2diigo.py]. Here's the full text:

{% highlight python %}
    #!/usr/bin/python
    
    # Based on diigo.py, which is copyright (c) 2008 Kliakhandler Kosta
    # <Kliakhandler@Kosta.tk> and released under the GNU Public License.
    #
    # This hacked version is also released under the GNU Public License.
    # This program is free software: you can redistribute it and/or modify
    # it under the terms of the GNU General Public License as published by
    # the Free Software Foundation, either version 3 of the License, or
    # (at your option) any later version.
    
    # ---------------------------------------------------------------------------
    # Configuration
    #
    # CHANGE THESE VALUES
    
    DELICIOUS_USER = 'username'
    DELICIOUS_PASSWORD = 'password'
    DIIGO_USER = 'username'
    DIIGO_PASSWORD = 'password'
    
    #############################################################################
    # Should not need to change anything below here.
    #############################################################################
    
    import simplejson as json
    import urllib2 # For interacting with the diigo servers
    import urllib # For encoding queries to be transmitted via POST
    import time # For waiting between queries
    import sys # For the logging methods.
    from xml.dom import minidom
    import simplejson as json
    
    # ---------------------------------------------------------------------------
    # Constants
    
    DELICIOUS_BOOKMARKS_URL = 'http://%s:%s@api.del.icio.us/v1/posts/all' % (DELICIOUS_USER, DELICIOUS_PASSWORD)
    DIIGO_API_SERVER = 'api2.diigo.com'
    DIIGO_BOOKMARKS_URL = 'http://api2.diigo.com/bookmarks'
    # The diigo api only allows to add up to 100 bookmarks at a time.
    UPLOAD_CHUNK_SIZE = 100
    
    # ---------------------------------------------------------------------------
    # Functions
    
    def upload_diigo_bookmarks(username, bookmarks):
        init_basic_auth(DIIGO_USER, DIIGO_PASSWORD, DIIGO_API_SERVER)
        for bookmark in bookmarks:
            # Delete unnecessary fields to conserve bandwidth.
            # The diigo api ignores them at the moment.
            if bookmark.has_key('user'): del bookmark['user']
            if bookmark.has_key('created_at'): del bookmark['created_at']
            if bookmark.has_key('updated_at'): del bookmark['updated_at']
    
            if type(bookmark) == dict:
                # The diigo api requires the tag list to be a comma seperated
                # string, so if it is a dict we parse and format it
                tags = ''
                for tag in bookmark['tags']:
                    tags += tag + ', '
                else:
                    tags = tags[:-2]
                bookmark['tags'] = tags
    
        print("Uploading bookmarks to %s in chunks of %d." %
              (DIIGO_API_SERVER, UPLOAD_CHUNK_SIZE))
    
        while bookmarks:
    
            # Take UPLOAD_CHUNK_SIZE bookmarks, at most
            chunk = bookmarks[0:UPLOAD_CHUNK_SIZE]
            del bookmarks[0:UPLOAD_CHUNK_SIZE]
    
            # Turn the list into json for sending over http
            payload = json.dumps(chunk)
    
            titles = map(lambda b: b['title'], chunk)
    
            # Encode the json into a safe format for transmission
            print('\nSubmitting:')
            for t in titles:
                print("\t%s" % t)
    
            upload_to_diigo(urllib.urlencode({'bookmarks' : payload}))
    
        return len(bookmarks)
    
    def upload_to_diigo(payload):
        keep_trying = True
        while keep_trying:
            # Submit the bookmark
            try:
                response = urllib2.urlopen(DIIGO_BOOKMARKS_URL, payload)
                print("Server response: " + response.read())
                keep_trying = False
            except urllib2.HTTPError, e:
                if e.code == 503: # service unavailable; try again
                    print('HTTP Error 503. Retrying.')
                    time.sleep(5)
                else:
                    raise
    
    def load_delicious_bookmarks(url):
        print('Loading Delicious bookmarks.')
        dom = minidom.parse(urllib.urlopen(url))
        bookmarks = []
        for e in dom.getElementsByTagName('post'):
            tags = e.attributes['tag'].value.split(' ')
            b = { 'url'    : e.attributes['href'].value,
                  'title'  : e.attributes['description'].value,
                  'tags'   : tags,
                  'shared' : 'yes' }
            bookmarks.append(b)
    
        return bookmarks
    
    def main(delicious_bookmarks_url):
        # Set up urllib2 to authenticate with the old user's credentials.
        bookmarks = load_delicious_bookmarks(delicious_bookmarks_url)
        upload_diigo_bookmarks(DIIGO_USER, bookmarks)
    
    def init_basic_auth(user, password, naked_url):
        """
        Sets up urllib2 to automatically use basic authentication
        in the supplied url (which is supplied w/o the protocol)
        using the supplied username and password
        """
        passman = urllib2.HTTPPasswordMgrWithDefaultRealm()
    
        # This will use the supplied user/password for all
        # child urls of naked_url because of the 'None' param.
        passman.add_password(None, naked_url, user, password)
    
        # This creates and assigns a custom authentication handler
        # for urllib2, which will be used when we call urlopen.
        authhandler = urllib2.HTTPBasicAuthHandler(passman)
        opener = urllib2.build_opener(authhandler)
        urllib2.install_opener(opener)
    
    if __name__ == "__main__":
        import os.path
        if len(sys.argv) > 1:
            bookmarks_url = 'file://' + os.path.abspath(sys.argv[1])
        else:
            bookmarks_url = DELICIOUS_BOOKMARKS_URL
    
        main(bookmarks_url)

{% endhighlight %}
