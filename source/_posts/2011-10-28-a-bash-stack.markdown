---
layout: post
comments: false
title: "A bash stack"
date: 2011-10-28 00:00
categories: [bash, shell, programming]
---

# A stack? In *bash*?

For reasons I won't go into here, I needed a simple stack implementation.
In *bash*.

Now, stack implementations aren't difficult, and *bash* does have arrays.
But *bash* does *not* have classes or objects, and I wanted a general-purpose
solution, not a quick-and-dirty, one-use hack.

# The specification

The specification for my stack implementation is simple and straightforward.
I wanted the following functions:

`stack_new name`

> Create a stack with the specified name. The name is akin to a variable
> name and follows the same naming conventions.

`stack_push name value ...`

> Push one or more values onto the stack called *name*.

`stack_pop name variable`

> Pop the top value from the stack called *name*, storing the result in the
> named variable.

`stack_destroy name`

> Destroy the stack called *name*

`stack_size name variable`

> Store the size of the stack called *name* in the specified variable.

`stack_print name`

> Display the contents of the stack called *name* on stdout.

I didn't bother with `stack_clear`, since `stack_destroy` followed by
`stack_create` is good enough. It'd be simple enough to add a `stack_clear`
function, though.

# Example

    stack_new foo
    stack_push foo 10 20 30
    stack_print foo          # prints: ( 30 20 10 )
    stack_pop foo i          # i is now 30. Stack is now ( 30 20 )

# The implementation

The implementation is, to put it bluntly, rather ugly. But, as my first
boss (many years ago) was fond of saying, "If the solution has to be ugly,
at least hide the ugly." The ugly is hidden in the implementation, where I
don't have to look at it.

So, without further ado, here's the code:

{% gist 1323553 %}

The code is also checked into my GitHub [bashlib][] repository, as `stack.sh`.

[Ruby]: http://ruby-lang.org/
[Rails]: http://rubyonrails.org/
[rvm]: https://rvm.beginrescueend.com/
[Python]: http://www.python.org/
[pythonbrew]: https://github.com/utahta/pythonbrew
[bashlib]: https://github.com/bmc/bashlib
