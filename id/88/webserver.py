
from invitemedia.library.twisted.internet import ReactorFinder
from twisted.internet import reactor
from twisted.web import resource, server
import threading
import sys

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
        timestamp = time.strftime('%H:%M:%S', time.localtime())
        thread = threading.currentThread().getName()
        print '[%s] (%s) %s' % (timestamp, thread, msg)

class WebServer(resource.Resource, Talkative):

    isLeaf = True

    def __init__(self):
        Talkative.__init__(self, 'WebServer')

    def render_GET(self, request):
        self.say('GET received')
        return CANNED_RESPONSE

    def render_HEAD(self, request):
        self.say('HEAD received')
        return resource.Resource.render_HEAD(self, request)

if __name__ == '__main__':
    if (len(sys.argv) > 1) and (sys.argv[1].lower() == 'debug'):
        Talkative.debug = True

    site = server.Site(WebServer())

    reactor.listenTCP(9999, site)
    reactor.run()
