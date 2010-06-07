import socket
import sys
import SocketServer
import threading
import optparse

CANNED_HEADERS = \
"""HTTP/1.1 200 OK
Date: Sat, 07 Mar 2009 12:20:25 GMT
Server: SocketServer-TCP
Accept-Ranges: bytes
Content-Length: 45
Connection: close
Content-Type: text/html

"""

CANNED_RESPONSE = CANNED_HEADERS + "<html><body><h1>It works!</h1></body></html>"

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
        print '[%s] (%s) %s: %s' % (timestamp, thread, self.name, msg)
        
    announce = __do_say

class Server(SocketServer.ThreadingMixIn, SocketServer.TCPServer, Talkative):
    
    daemon_threads = True
    allow_reuse_address = True

    def __init__(self, server_address, request_handler_class):
        Talkative.__init__(self, 'Server')
        SocketServer.TCPServer.__init__(self, server_address, 
                                        request_handler_class)
        self.say('Starting server.')

class RequestHandler(SocketServer.BaseRequestHandler, Talkative):

    def __init__(self, request, client_address, server):
        Talkative.__init__(self, 'Server')
        SocketServer.BaseRequestHandler.__init__(self, request, 
                                                 client_address, server)

    def handle(self):
        sock = self.request
        line = ''
        newline = False
        while not newline:
            buf = sock.recv(4096)
            for c in buf:
                line += c
                if c == '\n':
                    newline = True
                    break

        line = line.strip()
        if line.startswith('GET '):
            self.say('Got GET request')
            sock.sendall(CANNED_RESPONSE)
        elif line.startswith('HEAD '):
            self.say('Got HEAD request')
            sock.sendall(CANNED_HEADERS)
        else:
            self.say('Got unknown command: "%s"' % line)

        sock.close()
        
    def finish(self):
        pass

if __name__ == '__main__':
    if (len(sys.argv) > 1) and (sys.argv[1].lower() == 'debug'):
        Talkative.debug = True
    
    server = Server(('', 9999), RequestHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        sys.exit(0)

