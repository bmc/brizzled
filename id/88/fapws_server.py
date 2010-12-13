#!/usr/bin/env python

import fapws._evwsgi as evwsgi
from fapws import base
import time
import sys
from fapws.contrib import views, zip, log

CANNED_RESPONSE = "<html><body><h1>It works!</h1></body></html>"

class Talkative(object):
    
    debug = False

    def __init__(self, name):
        self.name = name
        
        if self.debug:
            self.say = self.__do_say
        else:
            self.say = self.__noop
            
    def __noop(self, msg):
        pass
    
    def __do_say(self, msg):
        import time
        import threading
        timestamp = time.strftime('%H:%M:%S', time.localtime())
        thread = threading.currentThread().getName()
        print '[%s] (%s) %s: %s' % (timestamp, thread, self.name, msg)
        
    announce = __do_say

class Server(Talkative):

    def __init__(self):
        Talkative.__init__(self, 'Server')

    def start(self):
        evwsgi.start("0.0.0.0", 9999)
        evwsgi.set_base_module(base)
        
        evwsgi.wsgi_cb(("/", self.top))
    
        evwsgi.set_debug(0)    
        evwsgi.run()
    
    def top(self, environ, start_response):
        self.say('Received request.')
        start_response('200 OK', [('Content-Type','text/html')])
        return [CANNED_RESPONSE]
    

if __name__== '__main__':

    if (len(sys.argv) > 1) and (sys.argv[1].lower() == 'debug'):
        Talkative.debug = True

    Server().start()
