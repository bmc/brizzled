---
layout: article
title: Why is Python more fun than Java?
tags: java, python, programming
date: 2008-07-28 00:00:00
toc: toc
---

# Intro

For nearly nine years, I worked almost exclusively in [Java][]. For me,
Java was a productivity enhancer, over C and C++, and I greatly enjoyed
working in it. Lately, however, I've been programming in [Python][] almost
exclusively, and I'm having so much fun with it that I have little desire
to go back to programming in Java.

Given that I developed code quite happily in Java for a long time,
this is an interesting, though not unprecedented, turn of events.

I've been mulling over why I find programming in Python to be so
much more fun . In this article, I am going to capture and explore
some of those thoughts.

But first, a few caveats and disclaimers:

* These comments are *entirely* subjective. I am not attempting a rational,
  scientific, rigorous analysis of these two languages; nor do I claim to
  be making a comprehensive comparison of Java and Python. I'm only sharing
  some musings.
* I do *not* suddenly hate Java. If you're a Java enthusiast and this
  article makes you want to yank out the [napalm][], realize that (a) I'm
  not bashing Java, and (b) I'm wearing my [asbestos longjohns][]. I've
  been a Java programmer for a long time, and I bear no ill will toward a
  language I happily used for many years. I'm just trying to capture why I
  find Python to be more fun.
* I am ignoring architectural reasons to favor one platform over the other.
  In a real system, these considerations must be taken into account. I'm
  ignoring them here because I am *only* trying to figure out why the
  Python programming language seems to be more fun to program than Java
  does (to me).
* I'm not a mindless Python fanboy. I was honestly surprised by how much
  fun I found Python programming to be, and I've been mentally exploring
  *why* I find it so much fun. This article is really little more than a
  brain dump of those thoughts.
* I'm sure Your Favorite Language is every bit as much fun as Python, but
  I'm not programming in Your Favorite Language right now. I'm comparing
  one language I used almost exclusively for nine years with another one
  I've delved into very deeply in this last year.

Having said all that, there will still be people who bash me and this
article because (a) they think I'm disrespecting their Java, (b) they think
I've left out some important stuff, (c) they're annoyed that I didn't
consider how much fun Groovy or Erlang or Ruby or ... are, (d) view me as
some sort of Java [Benedict Arnold][] or (e) they just don't like what I
have to say.

Oh, well.

*adjusts longjohns*

I've organized this article as a set of observations, with an
explanation of my thinking immediately following each observation.

# Observation 1: Python is a unique mixture of readability and brevity

The first reaction nearly *everyone* has about Python is, "Indentation is
part of the language's syntax? Yuck!" That was my first reaction, too. But,
as it turns out, that feature contributes greatly to Python's readability.
Most people indent their code *anyway*, but most languages ignore
indentation; they rely, instead, on syntax elements (curly braces, `do` and
`end` keywords, etc.) to determine where code blocks begin and end.
Python's awareness of indentation dispenses with the need for curly braces
or `do`/`end` keywords, leading to a brevity of syntax that still retains
its readability.

As an example, compare the following Java code and Python code snippets,
both of which do the same job.

Java:

{% highlight java %}
    public class Test
    {
         public static void main(String[] args)
         {
             for (String s : args[0].split("\\s+"))
                 System.out.println(s);
    
             System.exit(0);
         }
    }
{% endhighlight %}

Granted, the `System.exit(0)` doesn't really need to be there; I got in the
habit of putting it in, though, when using versions of Java that wouldn't
exit properly without such a call. But even if you remove that line, it's
still more verbose than the Python version:

{% highlight python %}
    import sys
    
    for s in sys.argv[1].split():
        print s
{% endhighlight %}

Yes, I could make the Java example shorter by putting the braces on the
same line as the code, as most people do, but I actually find that to be
even *less* readable. (That' a personal stylistic preference. It has little
to do with the real point of this article.)

The point is, Python's syntax is brief without being overly terse.

But it gets even more pronounced.

# Observation 2: No need for set/get methods in Python

Python code doesn't typically use the `get` and `set` methods so common in
Java. Normally, when writing Java code, you carefully protect your instance
variables by making the private, so callers can only interact with them via
getter and setter methods. Why? Well, consider this scenario. Suppose you
write a class called `Point` that looks something like this:

{% highlight java %}
    public class Point
    {
        public int x;
        public int y;
    
        public Point(int x, int y)
        {
            this.x = x;
            this.y = y;
        }
    }
{% endhighlight %}

Pretty soon, all over the code base, people are writing code like this:

{% highlight java %}
    point1 = new Point(...)
    point2 = new Point(...)
    point2.x = point1.x - deltaX
    point2.y = point1.y - deltaY
{% endhighlight %}

That's actually quite readable, but there's a problem: Suppose your
requirements change, and now you have to ensure that all coordinates are
positive.

Crap.

Now you realize that you *should* have written your `Point` class like
this:

{% highlight java %}
    public class Point
    {
        private int x;
        private int y;
    
        public Point(int x, int y)
        {
            this.x = x;
            this.y = y;
        }
    
        public int getX()
        {
            return this.x;
        }
    
        public int setX(int newX)
        {
            this.x = newX;
        }
    
        public int getY()
        {
            return this.y;
        }
    
        public int setY(int newY)
        {
            this.y = newY;
        }
    }
{% endhighlight %}

If you'd written it *that* way, people would've had to use it like this:

{% highlight java %}
    point1 = new Point(...)
    point2 = new Point(...)
    point2.setX(point1.getX() - deltaX)
    point2.setY(point1.getY() - deltaY)
{% endhighlight %}

`point2.setX(point1.getX() - deltaX)` isn't anywhere near as intuitive or
nice-looking as `point2.x = point1.x - deltaX`, but it's a lot safer. And
if you'd written it that way, you would only have to go into the `set()`
methods and add your constraint checks to ensure the arguments are
positive, without having to go change a whole bunch of calling code. For
instance:

{% highlight java %}
    public int setX(int newX)
    {
        if (newX > 0)
            throw new IllegalArgumentException("Negative X value.");
    
        this.x = newX;
    }
{% endhighlight %}

Okay, why is Python's solution to this problem more readable? Because
Python has a neat construct called a *property*. As Python's inventor,
Guido van Rossum, puts it:

> Properties are a neat way to implement attributes whose usage
> resembles attribute access, but whose implementation uses method
> calls. These are sometimes known as "managed attributes".

Basically, a property is a way to make a function call look like an
instance variable reference, which allows one to write code that adheres
better to the [Uniform Access Principal][]. Let's take our example, above,
and do it in Python. First, the `Point` class:

{% highlight python %}
    class Point(object):
    
        def __init__(self, x, y):
            self.x = x
            self.y = y
{% endhighlight %}

(You'll note that it's a tad shorter than the equivalent Java class, while
being just as readable.)

So, as before, people start using your `Point` class:

{% highlight python %}
    point1 = Point(...)
    point2 = Point(...)
    point2.x = point1.x - delta_x
    point2.y = point1.y - delta_y
{% endhighlight %}

Okay, now along comes that pesky requirement that all coordinates must be
positive. Instead of going back and changing all the callers to use new
`set` methods, you can simply wrap access to `x` and `y` in functions, as
show below.

{% highlight python %}
    class Point(object):
    
        def __init__(self, x, y):
            self.__x = x
            self.__y = y
    
        def getx(self):
            return self.__x
    
        def setx(self, newx)
            if newx > 0:
                raise ValueError, 'Negative X value'
    
            self.__x = newx
    
        x = property(getx, setx, doc='X coordinate')
    
        def gety(self):
            return self.__y
    
        def sety(self, newy)
            if newy > 0:
                raise ValueError, 'Negative Y value'
    
            self.__y = newy
    
        y = property(gety, sety, doc='Y coordinate')
{% endhighlight %}

Now, whenever someone writes `point.x`, they're really calling
`point.getx()`. Similarly, `point.x = 1` results in a call to the
`point.setx()` method.

You've added getters and setters, but the callers of your `Point` class
still get to use the original, simpler, easier-to-read syntax for accessing
the value. You get the best of both worlds: clean and simple client access
to your `Point` class, and protection and flexibility *within* the class.

Again, this tends to lead to more readable code.

# Observation 3: Python has useful constructs Java lacks

Python has some features that both make it easier to code certain common
constructs and contribute to the resulting code's readability. Here are a
few examples.

## Function Objects

In Python, functions are first class objects. That is, you can define a
function pretty much anywhere you want, then call it or use a reference to
it. This is beneficial in many areas, but for illustration, I'll focus on
just two:

- Callbacks
- Factory methods

### Callbacks ### {#callbacks}

Between interfaces and inner classes, Java can accomplish a lot of
the things people use callback functions for, but functions are
more compact, more flexible, and easier to read.

For example, consider a function to traverse a data structure (a
tree, for instance) to find objects that match certain criteria.
The matching function is generic: It traverses the structure and
calls a caller-supplied matching function to match two objects. It
makes sense to have the tree class supply the matching logic (which
hides the details of efficiently traversing the tree), while
allowing the caller to specify the matching function.

Here's how you might implement that logic in Java, using an interface.

{% highlight java %}
    import java.util.Collection;
    import java.util.ArrayList;
    
    public interface Matcher<T>
    {
        boolean matches(T o);
    }
    
    public class MyTree<T>
    {
        // details omitted
    
        Collection<T> matches(Matcher matcher)
        {
            Collection<T> result = new ArrayList<T>();
    
            for (element : this.treeElements)
                if (matcher.matches(element))
                    result.add(element);
    
            return result;
        }
    }
{% endhighlight %}

And here's how a caller might use it, using an anonymous inner class:

{% highlight java %}
    MyTree<String> keywords = new MyTree<String>();
    
    // Code that fills the tree goes here
    
    // Now, get all keywords starting with 'a'. (Yeah, it's contrived...)
    
    Collection<String> matches = keywords.matches
        (new Matcher<String>()
         {
             public boolean matches(String s)
             {
                 return s.startsWith("a");
             }
         });
{% endhighlight %}

Now let's look at the same thing in Python. First the class:

{% highlight python %}
    class MyTree(object):
    
        # details omitted
    
        def matches(self, match_func):
            return [element for element in self.__tree_elements if match_func(element)]
{% endhighlight %}

And now the caller:

{% highlight python %}
    keywords = MyTree()
    
    # Code that fills the tree goes here

    # Now, get all keywords starting with 'a'.
    
    matches = keywords.matches(lambda element: element.startswith('a'))
{% endhighlight %}

It's also possible to use a "real" function, rather than a `lambda`:

{% highlight python %}
    def match(element):
        return element[0] == 'a'
    
    matches = keywords.matches(match)
{% endhighlight %}

In simple cases like this, however, it's easier and more straightforward to
use a lambda.

Once again, the Python code is simpler and (in my opinion) easier to read
and faster to code.

### Factories

In Java, a factory is typically a static method that is called to
produce an object. Factories are used for a variety of reasons,
including:

- Construction of singletons.
- Hiding instantiation of one of several possible underlying implementations.

In Java, since methods cannot occur outside of a class, you are sometimes
forced to write a class just to provide a factory function. Here's an
example. Consider a remote procedure call (RPC) layer that has many
different RPC implements (e.g., "XML-RPC", "JSON-RPC", "SOAP", etc.) Each
implementation is encoded in a concrete class, and all classes adhere to a
specific interface:

{% highlight java %}
    public interface RPC
    {
        public Object callRemote(String function, Object ... args);
    }
    
    class XMLRPC implements RPC
    {
        // ...
    
        public Object callRemote(String function, Object ... args)
        {
            // ...
        }
    }
    
    class JSONRPC implements RPC
    {
        // ...
    
        public Object callRemote(String function, Object ... args)
        {
            // ...
        }
    }
    
    // etc.
{% endhighlight %}

Now, suppose your application is going to support a configuration option
that allows the user to specify the desired RPC mechanism using a string,
and you want to map that string to an instance of the appropriate RPC
class. The easiest solution is a factory method. But where to you put that
method? You can't hang it off the `RPC` interface, because that's just an
interface. You have two choices:

1. Convert the `RPC` interface to an abstract class, and put the method
   there. Doing that, of course, means that RPC subclasses can't extend any
   other abstract classes, which may cause some implementation headaches
   (or might not, depending).
2. Create a special `RPCFactory` class, which is clumsy, but is probably
   the safest way to go.

{% highlight java %}
    public class RPCFactory
    {
        public static RPC getRPC(String identifier)
        {
            if (identifier.toLowerCase().equals("xmlrpc"))
                return new XMLRPC()
            ...
        }
    }
{% endhighlight %}

With Python, it's easier: Simply create a factory method right in your
module. To make things even simpler, you can use a hash table to look up
the implementing classes. (You can do that with Java, too, but you end up
having to use the Reflection API, which is clumsier than in Python. (See
*Observation 4: Introspection is easier in Python*, below.)

{% highlight python %}
    RPC_CLASSES = {'xmlrpc'  : XMLRPC,
                   'jsonrpc' : JSONRPC,
                   ... }
    
    def get_rpc(identifier):
        try:
            return RPC_CLASSES[identifier]()
        except KeyError:
            raise ValueError, '"%s" is an unknown RPC type' % identifier
{% endhighlight %}

## Closures

Python doesn't have true closures, in the Ruby or LISP sense of the term,
but it's a heck of a lot closer than Java. While there are proposals to add
(true) closures to Java (such as [this one][]), it doesn't have them yet,
and it may be awhile until it does.

The closest thing Java has to a closure is an anonymous inner class, and it
isn't really a closure. It's also clumsy to use and can lead to less
readable code.

I'm not going to go into the differences between inner classes and
closures; there are plenty of discussions on that issue already. For
further reading, here are a few pointers:

* [Closures and Java: A Tutorial][]
* [Yet another reason for why Java needs Closures][]

Since I'm mostly concerned about "fun", readability and productivity, let's
look at one example. Closures are useful for a *lot* of things; this is
just one simple example. I've adapted this scenario from [Neal Gafter][]'s
[Use cases for closures][] blog entry.

The situation is simple: You have to provide a function that increments a
counter for a key; the counters are stored in a hash table-like object. If
the counter for a key isn't present, then it must be created and
initialized to 1. The wrinkle is that the hash table-like object is in a
shared resource. (Perhaps it's a file, or perhaps it's shared memory; that
part doesn't matter here.) Since the table is shared, it must be locked to
prevent corruption. You have to be sure to release the lock, even if an
error occurs.

The standard pattern for this approach (using Python, in this case) is
something like:

{% highlight python %}
    def increment(key):
        self.lock.lock()
        try:
            value = self.counter_table.get(self, key)
            if not value:
                self.counter_table.add(key, 1)
                value = 1
            return value
        finally:
            lock.unlock()
{% endhighlight %}

There are two problems with that code:

1. You end up with that locking pattern all over your code. Wouldn't it be
   nice to hide it somewhere? Wouldn't it *really* be nice if it were part
   of the lock API?
2. The lock API cannot enforce that pattern. The requirement can be
   documented it, and the documentation can wag its finger (as it were) at
   the programmer, saying, "Always, always, *always* make sure you release
   your locks!" But it cannot *enforce* the restriction programmatically.
   And if someone forgets the `finally` block, he'll introduce a bug--one
   that's often tricky to track down.

Closures solve that problem. Using closures, you can augment the locking
API (or write a local front-end function) that looks like this:

{% highlight python %}
    def with_lock(lock, action, *args, **keyword_args):
        try:
            lock.lock()
            action(*args, **keyword_args)
        finally:
            lock.unlock()
{% endhighlight %}

Now our function becomes much simpler:

{% highlight python %}
    def increment(key):
        value = None
    
        def do_incr(key):
            value = self.counter_table.get(key)
            if not value:
                self.counter_table.add(key, 1)
                value = 1
    
        with_lock(self.lock, do_incr, key)
{% endhighlight %}

Better yet, the locking semantics are enforced in one place: the
`with_lock()` function.

Note that the `do_incr()` function has access to, and can change, the
parent function's `value` object. It *closes over* any objects already in
scope when it is declared, hence the term "closure".

You cannot do the same thing in Java, even with an anonymous inner
class, because any objects your inner class closes over must be
`final`.

Newer versions of Python make it even easier by providing a `with`
statement (available in the `__future__` module). For complete details, see
[PEP 343][], but here's the general idea.

First, the lock API can provide a *context manager* function, like this:

{% highlight python %}
    from contextlib import contextmanager
    
    @contextmanger
    def lock(the_lock):
        the_lock.lock()
        try:
            yield the_lock
        finally:
            the_lock.unlock()
{% endhighlight %}

Now, the calling code becomes even more straightforward:

{% highlight python %}
    from __future__ import with_statement
    
    def increment(key):
        with lock(self.lock):
            value = self.counter_table.get(key)
            if not value:
                self.counter_table.add(key, 1)
                value = 1
{% endhighlight %}

You can't do that in Java very cleanly right now, though the various
closures proposals, targeted at Java 7, attempt to address that problem.
Neal Gafter's [Use cases for closures][] goes through his favored closure
proposal in detail. Using that approach, you'd do something like this:

{% highlight java %}
    <E extends Exception>
    public static void withLock(Lock lock, void()throws E block) throws E 
    {
        lock.lock();
        try 
        {
            block();
        }
        finally 
        {
            lock.unlock();
        }
    }
{% endhighlight %}

That block of code defines the method that will run my code within a lock.
The Java closure proposal also adds some syntactic sugar that says,
basically, "if the passed block argument is the last argument in the list,
it can be specified *outside* the argument list's final parenthesis."

That means you can invoke `withLock()` like this:

{% highlight java %}
    withLock(myLock)
    {
        // code (closure) that operates within the lock
    }
{% endhighlight %}

The code between the curly braces is *really* the last argument to the
`withLock()` method. And it truly *is* a closure: Unlike an anonymous inner
class, the code block has read-write access to all the identifiers in the
parent block's scope.

I heard about the closures-in-Java proposals while I was still programming
Java for my previous employer. I was very excited about the idea, since it
makes a lot of programming tasks easier and safer. However, while adding
closures to Java would be a good thing, they're still not as simple as
closures are in other languages, such as Python.

## Array and String Support

Both Java and Python have built-in support for strings and arrays,
but Python has a lot more syntactic sugar for both, leading to
simpler and more readable code. Here are some examples:

### String or Array Slicing

In Java, to get a "slice" out of a string, you have to use methods
on the `java.lang.String` class, like so:

{% highlight java %}
    String s = "foo and bar"
    
    s1 = s.substring(4, 7);           // get the word "and"
    last = s.charAt(s.length() - 1);  // get the last character in the string
    first = s.charAt(0);              // get the first character in the string
{% endhighlight %}

The same operations are simpler and more readable in Python:

{% highlight python %}
    s = 'foo and bar'
    
    s1 = s[4:7]       # get the word 'and'
    last = s[-1]      # get the last character in the string
    first = s[0]      # get the first character in the string
{% endhighlight %}

Further, while Java allows strings to be concatenated via the "+"
operator, that usage is discouraged for building up strings, since
it can be inefficient. So, instead of the readable:

{% highlight java %}
    message = "I don't recognize the command \"" + s + "\". Sorry."
{% endhighlight %}

you end up writing:

{% highlight java %}
    buf = StringBuffer()
    buf.append("I don't recognize the command \"");
    buf.append(s);
    buf.append("\" Sorry.");
    message = buf.toString();
{% endhighlight %}

Oh, joy.

**UPDATE** In the [reddit.com][] [Programming][] forum, someone pointed out
that using "+" for string concatenation isn't really encouraged in Python,
either. The author of the comment suggests one of the following, instead:

{% highlight python %}
    message = 'I don\'t recognize the command "%s". Sorry.' % s
    message = ' '.join(['I don\'t recognize the command "', s, '". Sorry.'])
{% endhighlight %}

Fair enough, but my point still holds: Both of those alternatives are more
readable and shorter than the Java alternative.

Python also permits slicing and concatenation via "+" on arrays and tuples,
not just strings. (Think of a tuple as a read-only array.) Again, this
means you write less code to accomplish an array operation, and the code
you do write tends to be more readable.

## Dictionary Syntax ## {#dictionary_syntax}

Python has built-in support for dictionaries (also called "associative
arrays" in some languages and "hash tables" in others). In Java, you have a
variety of `Map` implementations that provide the same capability, and
they're quite rich. The JDK's `Map` interface is well-defined and
sufficiently abstract. I even wrote a [FileHashMap][] class that looks like
a `Map`, but keeps its values in a file rather than in memory.

But Java does not have built-in syntax support for maps, so dealing with
them requires more code. Consider this simple example, a symbol table of
keywords. Let's assume the existence of a `Symbol` class that captures
information about a symbol (the line where it's defined, its type, etc.).

{% highlight java %}
    public class SymbolTable
    {
        private Map<String,Symbol> symbols = new HashMap<String,Symbol>();
    
        // ...
    
        public Symbol getSymbol(String identifier)
        {
            // Get or create the symbol
    
            Symbol sym = symbols.get(identifier);
            if (sym == null)
            {
                sym = Symbol(identifier);
                symbols.put(identifier);
            }
    
            return sym;
        }
    }
{% endhighlight %}

Here's the equivalent Python code:

{% highlight python %}
    class SymbolTable(object):
    
        symbols = {}
    
        def get_symbol(identifier):
            try:
                sym = symbols[identifier]
            except KeyError:
                sym = Symbol(identifier)
                symbols[identifier] = sym
    
            return sym
{% endhighlight %}

It may seem like I'm nit-picking, but the Python approach just seems
simpler and more natural. (And believe me, I've used my share of Java `Map`
classes over the years.)

# Observation 4: Introspection is easier in Python

This is a big one. Both Java and Python carry object information around at
run time, and you can query that information programmatically. But it's a
pain in the ass in Java.

Let's suppose you want to write a function that'll take *any* object that
has a method with this signature:

{% highlight java %}
    boolean compare(String s1, String s2);
{% endhighlight %}

Further, you don't want to constrain the objects to implementing a specific
interface. (Though this situation doesn't sound likely, and isn't something
you'd normally want to do, it *does* come up.)

To do that in Java requires resorting to the [Reflection API][]. Here's the
code you have to write to verify that the object has such a method, and
then to call that method with two strings:

{% highlight java %}
    import java.lang.reflect.Method;
    
    ...
    
        public Object callCompare(Object o, String s1, String s2)
        {
            Class cls = o.getClass();
    
            try
            {
                Method method = cls.getMethod("compare", String.class, String.class);
                return method.invoke(o, s1, s2);
            }
    
            catch (NoSuchMethodException ex)
            {
                ...
            }
    
            catch (IllegalAccessException ex)
            {
                ...
            }
    
            catch (IllegalArgumentException ex)
            {
                ...
            }
    
            catch (InvocationTargetException ex)
            {
                ...
            }
{% endhighlight %}

That code is ugly for a few reasons. (It used to be worse, before Java 5
introduced variable arguments.)

* All those exceptions either have to be caught or propagated.
* If the method itself throws an exception, it'll be wrapped in an
  `InvocationTargetException`, and you have to unwrap it if you want to
  re-throw the real exception.
* Does the above code look like it's calling an object's `compare()` method
  to *you*?

Here's how you do the same thing in Python:

{% highlight python %}
    o = ...
    s1 = ...
    s2 = ...
    
    try:
        result = o.compare(s1, s2)
    except AttributeError:
        # Doesn't have that method.
        ...
{% endhighlight %}

In addition to being short and to-the-point, the Python code actually
*looks* like what it's doing.

# Observation 5: Python has an rich library

I mention this one only because Java also has a rich library. Between the
JDK and the open source Java code out there, there's lots of help building
Java applications.

When I started doing a lot of Python, I found the same thing to be true, so
I didn't lose anything there.

There *is* this sense, though, that a lot of things are just easier in
Python. For instance, the [Django][] web framework makes incrementally
building an application so easy, it's ridiculous. It's much easier to get
started with Django than with even a *simple* Java web container like
[Tomcat][]. (Of course, this isn't evidence; it's an anecdote. You're free
to draw your own conclusions.)

# Observation 6: Dynamic Typing (a mixed bag)

I mention [dynamic typing][] because so many people either tout it as the
best thing since sliced luncheon meats or decry it as an evil feature
considered as harmful as the GOTO statement. Reality, of course, is
somewhere in between--as is my experience.

There *are* more carefully considered opinions, of course, but they tend to
get lost in the noise. See, for instance, an excellent paper entitled
[Static Typing Where Possible, Dynamic Typing When Needed][] (PDF) for a
good and balanced discussion of the issue.

I'm not going to waste time debating which one is "better" (for some values
of "better"). There are plenty of people who do a better job of that than I
will. (Start with the paper I just mentioned, for instance.) I'm just going
to share my own experiences with the two approaches, using Java and Python
as my examples.

Recall that Java is statically typed, which has several advantages.

## Compiler-time checks

First, the compiler can ensure that you don't assign the wrong type of
object to a variable or pass the wrong type of object to a method (unless,
of course, you use type casting to thwart the compiler, but good Java
programmers try to avoid having to cast).

I have long been a fan of compile-time protection. The more problems the
compiler can find for you, the fewer things you have to root out at run
time. Oddly enough, though, I haven't found the lack of compile time type
checking to be a big problem with Python so far. I suspect this is because
I've been writing well-encapsulated code with lots of automated unit tests.
A paper called [Why dynamic typing?][] puts it this way:

> Why does dynamic typing (as done with Smalltalk) not negatively
> affect the stability of large applications?
> 
> Because large applications written in a dynamic OO language still
> have well encapsulated parts that can be verified independently,
> and the total implementation can be about 1/2 to 1/3 the size of
> the implementation in Java (or another static-typed language)
> 
> In the small you may get a type error that static-typing could have
> \[caught\], but you also get to build a system such that you never
> have to write 40-70% of the code you might otherwise have to. And a
> line of code not written is a 100% guaranteed correct line of
> code.

It's an interesting argument. I'm not sure I agree completely with the last
statement, but there's merit in the observations.

For me, so far, the lack of compile-time type protection in Python
simply hasn't been as big a deal as I thought it would be.

**UPDATE**: Over time, it turned out to be quite a big deal, which is why
I've migrated to [Scala][]; it offers a similar brevity of expression, while
being compile-time type-safe.

[Scala]: http://www.scala-lang.org/

## Syntax-based introspection

Another advantage of static typing is that IDEs can tell a variable's type
no matter where it appears, which is a boon for things like
auto-completion.

This is where I've most noticed the lack of type information. Lately, I've
been using the excellent [Wing][] IDE to develop Python. (Why I'm using
Wing instead of my old trusty friend, Emacs, is a subject for a future
article.) Unlike any Java IDE, there are cases where Wing just cannot tell
the type of a variable and, therefore, cannot help me determine what fields
and methods that variable provides. Here's a case where it *can* tell:

{% highlight python %}
    my_foo = Foo()
    
    my_foo.a
            ^
{% endhighlight %}

If I invoke auto-completion where the caret is, Wing can show me all
attributes that start with "a", because the assignment of a `Foo` object to
`my_foo` is within scope.

However, here's a case where it cannot tell:

{% highlight python %}
    def somefunc(foo):
        foo.a
             ^
{% endhighlight %}

At runtime, the argument `foo` can be anything, so the IDE cannot tell what
fields it might have (other than, of course, the fields that all Python
objects have).

Sometimes, I miss the ability for the IDE (or any other tool) to be able to
introspect a variable by syntactic analysis, but it honestly hasn't been
enough of an issue to take the fun out of Python.

# Observation 7: The Interactive Shell

Python comes with an interactive shell, and there's an even better one
(IPython) available for free. When I'm not sure how something works, or I
want to try something manually, or run a quick test, I can simply fire up
the Python shell and try the code, right then and there. (Ruby and other
so-called scripting languages have similar tools.)

It's impossible to overstate the usefulness of a command-line interface to
the language interpreter. Nothing quite like it exists for Java. The
[BeanShell][] console comes close, but the latest version as of this
writing doesn't fully support Java 5. (It's missing support for generics,
for instance.)

[Jack Repenning][] also pointed out, in a private email, that the brevity
argument applies here, as well:

> Even in environments with a fairly competent Java Interactive
> Shell, what you have to type in is still Java, and the extra
> prolixity of Java hurts all the more when you're just trying to
> confirm the results of a function call, or the shape of an object,
> or any of those other explorations the interactive shell is so good
> at.

# Final Comments

I'm sure there are differences I've missed. And, as I noted above, I'm not
trying to convince anyone who uses Java that it'd be better to jump ship
and join the [Pythonistas][].

I used Java for a long time, and I'm sure I'll do more work in Java. Nor
will I complain a lot if I have to do so. Both Java and Python (as well as
Ruby and other languages) allow me to develop and test my software on any
platform, unlike (say) most [C#][] work, which locks me into a platform I
don't like all that much (Mono notwithstanding).

I'm just trying to figure out why Python is so damned fun.

Time to stop thinking for a bit and have some fun...

# UPDATE: 29 July, 2008

I have received some emailed comments. Thanks to everyone who took
the time to send me a comment.

Both Dan Barbus *dan.barbus /at/ gmail.com* and Simon Lieschke *simon at
lieschke.net* pointed out an oversight. My original Python `matches()`
function (see [Callbacks][], above) was written like this:

{% highlight python %}
    def matches(self, match_func):
        for element in self.__tree_elements:
            if match_func(element):
                result.append(element)
    
        return result
{% endhighlight %}

Both Dan and Simon pointed out that the function can be reduced to
a one-liner:

{% highlight python %}
    def matches(self, match_func):
        return [element for element in self.__tree_elements if match_func(element)]
{% endhighlight %}

One-liner list comprehensions like that are one of the things I like about
Python, and I'm not sure why I wrote the function the "long" way
originally. Chalk it up to a brain fart.


* * * * *

Michael Easter (*codetojoy /at/ gmail.com*) noted out that, like
[BeanShell][], [Groovy][] also has a shell that allows interpretative Java.
So does [Pnuts][], a very fast Java scripting language I've used quite
heavily in the past. These are good tools to keep in one's Java toolbox.


* * * * *

Fred van Dijk (*fredvd /at/ gmail.com*) pointed out a cut-and-paste typo in
one of my examples. Thanks, Fred.

* * * * *

Florian Bosch (*pyalot /at/ gmail.com*) wrote:

> I've read your article and I think I you might find my perspective
> on dynamic typing also interesting, and why it actually works, and
> works very well.
> 
> To my shame I have to admit I'm not a big user of unit tests. I've
> used them to great effect sometimes, and some software I wrote has
> a lot of them, but generally there's very little of it around my
> code.
> 
> On any account, python still is making me way more productive, and
> if your argument was true, that your unit tests safe you from being
> harmed by dynamic typing, then I would be burned badly, but I am
> not. I think I can explain that.
> 
> Put simply, I think typing does not essentially catch the larger
> domain of logical errors that happen during programming. However,
> it does introduce considerable overhead. Logically, when you take
> typing constraints away, a small amount of errors that would've
> been cought before slip by to runtime, however you get a lot less
> overhead to deal with, which more then makes this up.
> 
> Put not so simply, Typing is a school of formalism that attempts to
> describe a systems constraints in terms of types involved. That is
> a special form of a constraint system, like clipse or prolog. These
> systems work great for specific domains, but they're not a great
> way to do all things. Enforcing constraint oriented programming on
> all parts of your code is not a very smart idea to increase
> productivity, because most code actually does not benefit from that
> particular flavor of constraint system.

Fair enough, though there are still times where I want both (or either).
Florian followed up with:

> Python actually has strong types, as opposed to say PHP or Perl.
> And you absolutely can write static looking code today in python,
> for instance:
> 
>     @types(int, str)
>     def foo(arg1, arg2):
>         pass
> 
> And annotations for python loom on the horizon, which would make it
> possible to write things like this:
> 
>     @typechecked
>     def foo(int arg1, str arg2):
>         pass

I'm not sure if this is coming in Python 3000 or not. (If someone knows,
please enlighten me.) I know that there are already some packages out there
that provide similar annotations, such as:

* The [typecheck][] module provides various typechecking features,
  including an `@accepts` annotation that looks a lot like the `@type`
  annotation noted above.
* [Pyanno][] also has some typechecking annotations.

# UPDATE: 16 September, 2008

Jésus Gómez (*jgomo3 /at/ gmail.com*) wrote:

> About Observation 3 and factories.
> 
> You could avoid the use of (and maintaining the) dict you use in
> this code:
> 
>     RPC_CLASSES = {'xmlrpc'  : XMLRPC,
>                    'jsonrpc' : JSONRPC,
>                    ... }
>     
>     def get_rpc(identifier):
>        try:
>            return RPC_CLASSES[identifier]()
>        except KeyError:
>            raise ValueError, '"%s" is an unknown RPC type' % identifier
> 
> by redefining the `get_rpc` function as:
> 
>     def get_rpc(identifier):
>        try:
>            return getattr(<<module_which_define_the_classes>>, identifier)()
>        except KeyError:
>            raise AttributeError, '"%s" is an unknown RPC type' % identifier
> 
> Take a look at the [Dive Into Python][] chapter on classes for a fun way
> to declare classes to act like dictionaries, useful for your
> [Dictionary Syntax][] section.

# UPDATE: 13 October, 2008

Regarding my `get_symbol()` method, in the section on
[Dictionary Syntax][], Kevin Samuel (*info.ksamuel* /at/ *googlemail.com*)
wrote:

> I'd like to share a little trick. When you say:
> 
>     class SymbolTable(object):
>     
>         symbols = {}
>     
>         def get_symbol(identifier):
>             try:
>                 sym = symbols[identifier]
>             except KeyError:
>                 sym = Symbol(identifier)
>                 symbols[identifier] = sym
>     
>             return sym
> 
> You could just use the built-in:
> 
>     d = {}
>     value = d.setdefault(identifier, default_value)
> 
> `setdefault` is a bad name since it does return a value or the
> default value (or `None` is no value is given).

The [Python documentation on dictionaries][] says:

> *a* `.setdefault` (*k*\[, *x*\]) returns *a*\[*k*\] if *k* in *a*,
> else *x* (also setting it)

It further elaborates:

> `setdefault()` is like `get()`, except that if *k* is missing, *x*
> is both returned and inserted into the dictionary as the value of
> *k*. *x* defaults to `None`.

I confess that I missed this behavior when I read the Python documentation.
Thanks, Kevin.

[Java]: http://java.sun.com/
[Python]: http://www.python.org/
[napalm]: http://en.wikipedia.org/wiki/Napalm
[asbestos longjohns]: http://www.catb.org/jargon/html/A/asbestos-longjohns.html
[Benedict Arnold]: http://en.wikipedia.org/wiki/Benedict_Arnold
[this one]: http://javac.info/
[Closures and Java: A Tutorial]: http://fishbowl.pastiche.org/2003/05/16/closures_and_java_a_tutorial
[Yet another reason for why Java needs Closures]: http://notdennisbyrne.blogspot.com/2008/06/yet-another-reason-for-why-java-needs.html
[Neal Gafter]: http://gafter.blogspot.com/
[Use cases for closures]: http://gafter.blogspot.com/2006/08/use-cases-for-closures.html
[PEP 343]: http://www.python.org/dev/peps/pep-0343/
[Use cases for closures]: http://gafter.blogspot.com/2006/08/use-cases-for-closures.html
[reddit.com]: http://www.reddit.com/
[Programming]: http://www.reddit.com/r/programming/
[FileHashMap]: http://software.clapper.org/java/util/javadocs/util/api/org/clapper/util/misc/FileHashMap.html
[Reflection API]: http://java.sun.com/docs/books/tutorial/reflect/index.html
[Django]: http://www.djangoproject.com/
[Tomcat]: http://tomcat.apache.org/
[dynamic typing]: http://en.wikipedia.org/wiki/Type_system#Dynamic_typing
[Static Typing Where Possible, Dynamic Typing When Needed]: http://pico.vub.ac.be/~wdmeuter/RDL04/papers/Meijer.pdf
[Why dynamic typing?]: http://www.chimu.com/publications/short/whyDynamicTyping.html
[Wing]: http://www.wingware.com/
[BeanShell]: http://www.beanshell.org/
[Jack Repenning]: http://blogs.open.collab.net/oncollabnet/
[image]: http://imgs.xkcd.com/comics/python.png
[Pythonistas]: http://python.net/~goodger/projects/pycon/2007/idiomatic/handout.html
[C#]: http://en.wikipedia.org/wiki/C_Sharp
[BeanShell]: http://www.beanshell.org/
[Groovy]: http://groovy.codehaus.org/
[Pnuts]: https://pnuts.dev.java.net/
[typecheck]: http://oakwinter.com/code/typecheck/
[Pyanno]: http://www.fightingquaker.com/pyanno/
[Dive Into Python]: http://diveintopython.org/toc/index.html
[Python documentation on dictionaries]: http://www.python.org/doc/2.5.2/lib/typesmapping.html
[Callbacks]: #callbacks
[Dictionary Syntax]: #dictionary_syntax
[Uniform Access Principal]: http://en.wikipedia.org/wiki/Uniform_access_principal
