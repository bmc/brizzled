import scala.actors.Actor
import scala.actors.Actor._
import java.net._
import java.io._
import java.text.SimpleDateFormat
import java.util.Date

trait Talkative
{
    val debug: Boolean
    val name: String

    final val df = new SimpleDateFormat("HH:MM:ss")

    // Depending on whether debug is set or not, define say() so that it's
    // either a call to print() or a no-op. This strategy pre-computes the
    // "if (debug)", instead of issuing the "if" statement every time say()
    // is called.

    private def _no_say(msg: String) = msg
    private def _say(msg: String) = print(msg)

    val say = if (debug) _say _ else _no_say _

    private def print(msg: String) =
        println("[" + df.format(new Date()) + "] (" +
                Thread.currentThread.getName + ") " + this.name + ": " +
                msg)

    /**
     * Announce something--i.e., print a message whether debug is enabled or
     * not.
     */
    def announce(msg: String) =
        print(msg)
}

case class Idle(worker: ServerWorker)
case class Connection(socket: Socket, id: Int)

/**
 * Worker actor. Services one connection, sending back a canned response,
 * then tells the dispatcher it's idle.
 */
class ServerWorker(val id: Int, val dispatcher: Dispatcher, val debug: Boolean)
    extends Actor with Talkative
{
    val name: String = "ServerWorker-" + id

    val CannedHeaders  = """|HTTP/1.1 200 OK
                            |Date: Sat, 07 Mar 2009 12:20:25 GMT
                            |Server: Scala Thingie
                            |Accept-Ranges: bytes
                            |Content-Length: 45
                            |Connection: close
                            |Content-Type: text/html
                            |
                            |""".stripMargin

    val CannedResponse = CannedHeaders +
                         "<html><body><h1>It works!</h1></body></html>"

    announce("Alive.")

    def act()
    {
        loop
        {
            react
            {
                case Connection(socket, id) =>
                    say("Got connection " + id)
                    handleConnection(socket)
                    say("Closing connection " + id)
                    socket.close()
                    say("Sending Idle message to dispatcher.")
                    dispatcher ! Idle(this)
            }
        }
    }

    override def hashCode(): Int = id

    override def equals(other: Any): Boolean =
        other match
        {
            case that: ServerWorker => this.id == that.id
            case _                  => false
        }

    def handleConnection(socket: Socket) =
    {
        val os = socket.getOutputStream
        val writer = new OutputStreamWriter(os)

        val is = socket.getInputStream
        val reader = new LineNumberReader(new InputStreamReader(is))

        readInput(reader, writer)
    }

    private val Get = "^(GET /.*)$".r
    private val Head = "^(HEAD /.*)$".r

    def readInput(reader: LineNumberReader, writer: Writer): Unit =
    {
        val line = reader.readLine()
        if (line != null)
        {
            val trimmed = line.trim
            say("Got line: \"" + trimmed + "\"")

            trimmed match
            {
                case Get(s) =>
                    say("Got: " + s)
                    writer.write(CannedResponse)
                    writer.flush()

                case Head(s) =>
                    say("Got: " + s)
                    writer.write(CannedHeaders)
                    writer.flush()

                case _ =>
                    say("Got unknown command: \"" + trimmed + "\"")
            }
        }
    }
}

/**
 * Dispatcher: Takes a connection and hands it off to an available worker.
 */
class Dispatcher(val debug: Boolean) extends Actor with Talkative
{
    val name: String = "Dispatcher"

    announce("Alive")

    import scala.collection.mutable.{Map, ListBuffer}
    import java.util.Random

    val idleWorkers = new ListBuffer[ServerWorker]
    val busyWorkers = Map[Int, ServerWorker]()
    val rng = new Random()

    for (i <- 1 to 1000)
    {
        val w = new ServerWorker(i, this, debug)
        w.start()
        idleWorkers += w
    }

    def act()
    {
        loop
        {
            react
            {
                // Process the Idle messages first.

                case Idle(worker) =>
                    say("Worker "  + worker.id + " is now free.")
                    busyWorkers -= worker.id
                    idleWorkers += worker

                case conn: Connection =>
                    // Get an idle worker. If there are no idle workers,
                    // then choose one randomly from the set of busy workers.
                    val worker = 
                        if (idleWorkers.length == 0)
                            busyWorkers.get(rng.nextInt(busyWorkers.size)).get
                        else
                        {
                            val w = idleWorkers.remove(0)
                            busyWorkers += w.id -> w
                            w
                        }

                    worker ! conn
            }
        }
        
    }
}

/**
 * Simple server. So simple, in fact, that it doesn't protect against too many
 * open files. (So beware.)
 */
class Server(val debug: Boolean) extends Talkative
{
    val name: String = "Main"

    def run() =
    {
        val socket = new ServerSocket(9999)
        val dispatcher = new Dispatcher(debug)
        var i = 0

        dispatcher.start()

        while (true)
        {
            say("Waiting for connection.")
            val clientConn = socket.accept()
            say("Accepted connection.")
            i += 1
            dispatcher ! Connection(clientConn, i)
        }
    }
}

//object server extends Application
object server
{
    def main(args: Array[String]) =
    {
        val debug = ((args.length > 0) && (args(0) == "debug"))
        new Server(debug).run()
    }
}
