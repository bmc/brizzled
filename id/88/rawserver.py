
from invitemedia.library.twisted.internet import ReactorFinder
from twisted.internet import reactor
from twisted.internet.protocol import Protocol, ServerFactory
import threading
import sys
from enum import Enum

CANNED_HEADERS = \
"""HTTP/1.1 200 OK
Date: Sat, 07 Mar 2009 12:20:25 GMT
Server: Twisted-TCP
Accept-Ranges: bytes
Content-Length: 45
Connection: close
Content-Type: text/html

"""

CANNED_RESPONSE = CANNED_HEADERS + "<html><body><h1>It works!</h1></body></html>"

RequestType = Enum('GET', 'HEAD')

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

class Worker(Protocol, Talkative):

    def __init__(self):
        Talkative.__init__(self, 'Worker')
        self.header_line_count = 0
        self.in_header = True
        self.request_type = None
        self.handled = False

    def connectionMade(self):
        self.say('Got connection.')
    
    def connectionLost(self, reason):
        self.say('Connection lost.')
    
    def dataReceived(self, data):
        lines = data.split('\n')
        for line in lines:
            if self.in_header:
                if self.header_line_count == 0:
                    self.say('Got: %s' % line)
                    if line.startswith('GET '):
                        self.request_type = RequestType.GET
                    elif line.startswith('HEAD '):
                        self.request_type = RequestType.HEAD
                    else:
                        self.say('Unknown request type: %s' % line)

                self.header_line_count += 1
                if line.strip() == "":
                    self.in_header = False
            else:
                if not self.handled:
                    self.handle_request(self.request_type)
                    self.handled = True
            
    def handle_request(self, request_type):
        if request_type == RequestType.HEAD:
            self.transport.write(CANNED_HEADERS)
        elif request_type == RequestType.GET:
            self.transport.write(CANNED_RESPONSE)
        self.transport.loseConnection()
        
class WorkerFactory(ServerFactory):
    
    protocol = Worker
    
    def __init__(self):
        pass

if __name__ == '__main__':
    if (len(sys.argv) > 1) and (sys.argv[1].lower() == 'debug'):
        Talkative.debug = True

    reactor.listenTCP(9999, WorkerFactory())
    reactor.run()
