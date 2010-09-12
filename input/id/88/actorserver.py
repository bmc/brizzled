import dramatis
import socket
import random
import sys
import optparse

CANNED_HEADERS = \
"""HTTP/1.1 200 OK
Date: Sat, 07 Mar 2009 12:20:25 GMT
Server: dramatis-HTTP
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
        import threading

        timestamp = time.strftime('%H:%M:%S', time.localtime())
        thread = threading.currentThread().getName()
        print '[%s] (%s) %s: %s' % (timestamp, thread, self.name, msg)
        
    announce = __do_say

class Connection(object):
    def __init__(self, sock, id):
        self.sock = sock
        self.id = id

class WorkerActor(dramatis.Actor, Talkative):

    def __init__(self, id, name, dispatcher):
        self.name = name
        Talkative.__init__(self, self.name)
        self._dispatcher = dispatcher
        self.id = id
        self.announce("Alive.")
        
    def handle_connection(self, conn):
        self.say("Got connection %s" % conn.id)
        self._process_connection(conn.sock)

        self.say("Closing socket.")
        conn.sock.close()
        self.say("Sending Idle message to dispatcher.")
        dramatis.release(self._dispatcher).idle(self.id)

    def _process_connection(self, sock):
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
    
    def __hash__(self):
        return self.id
    
    def __eq__(self, other):
        if isinstance(other, Worker):
            return self.id == other.id
        else:
            return False

class Worker(object):
    
    def __init__(self, dispatcher, id, name):
        self.dispatcher = dispatcher
        self.id = id
        self.name = name
        self.actor = WorkerActor(id, name, dispatcher)

class Dispatcher(dramatis.Actor, Talkative):
    def __init__(self):
        self._name = 'Dispatcher'
        Talkative.__init__(self, self._name)
        self.announce("Alive.")
        self.idle_workers = [Worker(self, i, 'Worker-%d' % i) for i in range(1, 1001)]
        self.busy_workers = {}

    def handle_connection(self, conn):
        if len(self.idle_workers) == 0:
            i = random.randint(0, len(self.busy_workers) - 1)
            key = self.busy_workers.keys()[i]
            worker = self.busy_workers[key]
        else:
            worker = self.idle_workers.pop()
            self.busy_workers[worker.id] = worker

        dramatis.release(worker.actor).handle_connection(conn)

    def idle(self, worker_id):
        worker = self.busy_workers[worker_id]
        del self.busy_workers[worker_id]
        self.idle_workers.append(worker)
        self.say('%s is idle.' % worker.name)

class Server(Talkative):
    def __init__(self):
        Talkative.__init__(self, 'Server')
        self.dispatcher = Dispatcher()

    def run(self):
        try:
            server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            server_socket.bind(('127.0.0.1', 9999))
            server_socket.listen(10)
            i = 0
            while True:
                self.say('Waiting for connection.')
                (sock, address) = server_socket.accept()
                self.say('Accepted connection.')
                i += 1
                conn = Connection(sock, i)
                dramatis.release(self.dispatcher).handle_connection(conn)
        finally:
            server_socket.close()

if __name__ == '__main__':
    if (len(sys.argv) > 1) and (sys.argv[1].lower() == 'debug'):
        Talkative.debug = True
    
    Server().run()
