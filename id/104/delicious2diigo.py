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
