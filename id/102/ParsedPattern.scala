import java.util.{Calendar, Date}
import java.text.{DateFormat, SimpleDateFormat}

class LogLevel(val value: Int, val label: String)

class LogMessage(val level: LogLevel,
                 val message: Any,
                 val name: String,
                 val date: Date)

class ParsedPattern(originalPattern: String)
{
    val parsedPattern: List[(LogMessage) => String] =
        parse(originalPattern.toList)

    lazy val Mappings = Map[Char, LogMessage => String](
        'a' -> insertDateChunk(new SimpleDateFormat("E")) _,
        'A' -> insertDateChunk(new SimpleDateFormat("EEEE")) _,
        'b' -> insertDateChunk(new SimpleDateFormat("MMM")) _,
        'B' -> insertDateChunk(new SimpleDateFormat("MMMM")) _,
        'd' -> insertDateChunk(new SimpleDateFormat("dd")) _,
        'D' -> insertDateChunk(new SimpleDateFormat("MM/dd/yy")) _,
        'F' -> insertDateChunk(new SimpleDateFormat("yyyy-MM-dd")) _,
        'h' -> insertDateChunk(new SimpleDateFormat("hh")) _,
        'H' -> insertDateChunk(new SimpleDateFormat("HH")) _,
        'j' -> insertDateChunk(new SimpleDateFormat("D")) _,
        'l' -> insertLevelName _,
        'L' -> insertLevelValue _,
        'M' -> insertDateChunk(new SimpleDateFormat("mm")) _,
        'm' -> insertDateChunk(new SimpleDateFormat("MM")) _,
        'n' -> insertName(true) _,
        'N' -> insertName(false) _,
        's' -> insertDateChunk(new SimpleDateFormat("ss")) _,
        'S' -> insertDateChunk(new SimpleDateFormat("SSS")) _,
        't' -> insertMessage _,
        'T' -> insertThreadName _,
        'y' -> insertDateChunk(new SimpleDateFormat("yy")) _,
        'Y' -> insertDateChunk(new SimpleDateFormat("yyyy")) _,
        'z' -> insertDateChunk(new SimpleDateFormat("z")) _,
        '%' -> copyLiteral("%") _
    )

    /**
     * Format a log message, using the parsed pattern.
     *
     * @param logMessage the message
     *
     * @return the formatted string
     */
    def format(logMessage: LogMessage): String =
        parsedPattern.map(_(logMessage)).mkString("")

    override def toString = originalPattern

    def insertThreadName(logMessage: LogMessage): String =
        Thread.currentThread.getName

    def insertLevelValue(logMessage: LogMessage): String =
        logMessage.level.value.toString

    def insertLevelName(logMessage: LogMessage): String =
        logMessage.level.label

    def insertMessage(logMessage: LogMessage): String =
        logMessage.message.toString

    def insertName(short: Boolean)(logMessage: LogMessage): String =
        if (short) logMessage.name.split("""\.""").last else logMessage.name

    def insertDateChunk(format: DateFormat)(logMessage: LogMessage): String =
    {
        val cal = Calendar.getInstance
        cal.setTimeInMillis(logMessage.date.getTime)
        format.format(cal.getTime)
    }

    private def datePatternFunc(pattern: String) =
        insertDateChunk(new SimpleDateFormat(pattern)) _

    private def copyLiteral(s: String)(logMessage: LogMessage): String = s

    private def escape(ch: Char): List[LogMessage => String] =
        List(Mappings.getOrElse(ch, copyLiteral("'%" + ch + "'") _))

    private def parse(stream: List[Char], gathered: String = ""):
        List[LogMessage => String] =
    {
        def gatheredFuncList = 
            if (gathered == "") Nil else List(copyLiteral(gathered) _)

        stream match
        {
            case Nil if (gathered != "") =>
                List(copyLiteral(gathered) _)

            case Nil =>
                Nil

            case '%' :: Nil =>
                gatheredFuncList ::: List(copyLiteral("%") _)

            case '%' :: tail =>
                gatheredFuncList ::: escape(tail(0)) ::: parse(tail drop 1)

            case c :: tail =>
                parse(tail, gathered + c)
        }
    }
}
