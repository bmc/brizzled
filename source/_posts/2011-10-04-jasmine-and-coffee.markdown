---
layout: post
comments: false
title: "Jasmine and Coffee"
date: 2011-10-04 00:00
categories: [javascript, coffeescript, testing, bdd]
---

# Introduction

While writing some [CoffeeScript][] field validation functions for a
client, I realized that I *really* needed a way to test the functions
outside of the browser. Initially, I just hacked together my own simple
[test framework][], which got the job done. However, I decided it'd be
better to use a more full-featured framework. I settled on [Jasmine][], a
[behavior-driven development (BDD)][BDD] testing framework for Javascript.

The remainder of this article describes how I am currently using Jasmine.
There are loads of other ways to use this excellent tool; this is just what
*I* am doing with it. I'm using Jasmine with [node.js][], at the command line.
Jasmine also supports integration with [Ruby][], [Rails][], [Django][],
and Java, among others.

# Preparation

## Node.js and npm

First, you'll need the [node.js][] Javascript framework. (Of course, since
you're using [CoffeeScript][], you already have that, right?) I also
recommend installing the [Node Package Manager (npm)][npm]. This document
assumes you're using [npm][], since it makes things a whole lot easier.

## Jasmine-Node and your test directory

Once you have [npm][] installed, create an empty directory to hold your
tests. Within that directory, install [Jasmine-Node][].

{% codeblock lang:bash %}
$ mkdir coffeetest && cd coffeetest
$ npm install jasmine-node
{% endcodeblock %}

You'll end up with a `node_modules` subdirectory.

## Rake, Buildr, Make, whatever

Let's make it easy to invoke the tests by creating a [Rake][] or [*make*][]
build file. I'll show examples of both here. However, since I'm using Rake,
I won't be mentioning *make* from here on.

First, the `Rakefile`:

{% codeblock lang:ruby %}
JASMINE_NODE = 'node_modules/jasmine-node/bin/jasmine-node'

task :default => [:test]

task :test do |t|
  sh JASMINE_NODE, "--coffee", "--verbose", "spec"
end
{% endcodeblock %}

Here's the GNU *make* equivalent:

    JASMINE_NODE = node_modules/jasmine-node/bin/jasmine-node

    test:
            $(JASMINE_NODE) --coffee --verbose spec

# Writing tests

## What I'm testing

Let's assume I have a CoffeeScript file called `util.coffee`, containing
some utility functions I want to test. For example:

{% codeblock lang:coffeescript %}
root = exports ? window

# ---------------------------------------------------------------------------
# Field validation functions
# ---------------------------------------------------------------------------

# Function: validZip
#
# Determine whether a string represents a valid (U.S.) zip code or zip+4.
#
# Parameters:
#   s - the string to validate
#
# Returns: true if valid, false if not
root.validZip = (s) ->
  s.match(root._zip_regex) != null

root._zip_regex = ///^\d{5}(-\d{4})?$///

# Ensures that an email address is valid.
#
# Parameters:
#    email - email address
#
# Return
#    true if valid, false if not
root.validEmail = (email) ->
  if email.match(root._email_regex) == null then false else true

root._email_regex = ///
  ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.[a-zA-Z]{2,4}$
  ///
{% endcodeblock %}

## Jasmine tests

### A brief overview

I'm not going to give a complete overview of Jasmine here; I assume you can
read the [Jasmine web site][Jasmine] to understand more about its
[suites and specs](https://github.com/pivotal/jasmine/wiki/Suites-and-specs),
[matchers](https://github.com/pivotal/jasmine/wiki/Matchers),
[spies (mockers)](https://github.com/pivotal/jasmine/wiki/Spies) and
[other capabilities](https://github.com/pivotal/jasmine/wiki). I'm only going
to mention the few Jasmine capabilities necessary for this article.

There are four main concepts that matter here:

* Test suites
* Tests
* The `expect` function
* Matchers

In Jasmine, a test suite groups individual tests and is defined with a
`describe` function wrapper. Each test within a suite is encapsulated within
an `it` function. In Javascript, a suite might look like this:

{% codeblock lang:javascript %}
describe("Simple Test"), function() {
  it("ensures that meaningOfLife() returns the right value", function() {
    expect(meaningOfLife()).toEqual(42);
  });
});
{% endcodeblock %}

In CoffeeScript, that same test is much more readable:

{% codeblock lang:coffeescript %}
describe "Simple Test", ->
  it "ensures that meaningOfLife() returns the right value", ->
    expect(meaningOfLife()).toEqual 42
{% endcodeblock %}

The `expect` call simply takes the value you want to test--in this case, the
result of a call to `meaningOfLife()`. The object it returns encapsulates that
value and provides a series of matchers, such as `toEqual()`, that can be
used to test that result.

### The actual tests

And now, the actual tests. Jasmine expects CoffeeScript tests to be in
files that end with `.spec.coffee`. So, these tests will be in
`spec/Validations.spec.coffee`. The test implementation is straightforward:


{% codeblock lang:coffeescript %}
# Pull in the utility functions we're testing.
util = require '../../coffeescripts/util.coffee'

# The test suite.
describe "Validations", ->

  # ----------------------------------------------------------------------

  it 'should properly validate email addresses', ->
    addresses =
      "bmc@example": false
      "bmc@example.com": true
      "bmc@example.com.": false
      "bmc@inside.example.com": true
      "bmc@": false
      "@example.com": false
      "false": false

    for addr, expected of addresses
      expect(util.validEmail(addr)).toEqual expected

  # ----------------------------------------------------------------------

  it 'should properly validate zip codes', ->
    zips =
      "1": false
      "19": false
      "194.": false
      "1940": false
      "19406": true
      "194061": false
      "1940612": false
      "19406123": false
      "194061234": false
      "19406-": false
      "19406-1": false
      "19406-12": false
      "19406-123": false
      "19406-1234": true
      "19406-12345": false
      "a9406-1234": false
      "19406-a234": false

    for zip, expected of zips
      expect(util.validZip(zip)).toEqual expected

  # ----------------------------------------------------------------------

  it 'should properly validate phone numbers', ->
    phones =
      "5": false
      "55": false
      "555": false
      "5551": false
      "55512": false
      "555121": false
      "5551212": false
      "555-1212": false
      "610-555-1212": true
      "(610)-555-1212": false
      "(610) 555-1212": true
      "(610) 5551212": true
      "610-5551212": true

    for phone, expected of phones
      normalized = util.validateTelephone(phone)
      ok = (normalized != null)
      expect(ok).toEqual expected
{% endcodeblock %}

Note that I'm using objects of test data to drive each test. That's obviously
not necessary; you could just as easily make multiple `expect` calls.

### Running the tests

Running the tests produces the following output:

    $ rake
    (in /home/bmc/src/coffeescripts/coffeetest)
    node_modules/jasmine-node/bin/jasmine-node --coffee --verbose spec
    Started
    ...

    Spec Validations
      it should properly validate email addresses
      it should properly validate zip codes
      it should properly validate phone numbers
    Finished in 0.002 seconds
    1 test, 37 assertions, 0 failures

You can get less verbose output simply by omitting the `--verbose` argument
to Jasmine. (I prefer the verbose output.)

If I deliberately break one of the tests, to cause a failure, I get output
like this:

    $ rake
    (in /home/bmc/src/coffeescripts/coffeetest)
    node_modules/jasmine-node/bin/jasmine-node --coffee --verbose spec
    Started
    ..F
    
    Spec Validations
      it should properly validate email addresses
      it should properly validate zip codes
      it should properly validate phone numbers
      Error: Expected false to equal true.
        at [object Object].<anonymous> (/home/bmc/src/coffeescripts/coffeetest/spec/Validations.spec.coffee:73:34)
    
    Finished in 0.004 seconds
    1 test, 37 assertions, 1 failure
    
    
    rake aborted!
    Command failed with status (1): [node_modules/jasmine-node/bin/jasmine-node...]
    /home/bmc/src/coffeescripts/coffeetest/Rakefile:13
    (See full trace by running task with --trace)

By default, on an ANSI-capable terminal or terminal emulator, the output is
colorized (not shown here).

# Conclusion

[Jasmine][] is an excellent Javascript test framework. Mix it with
[CoffeeScript][], and you get some serious deliciousness.

[npm]: http://npmjs.org/
[BDD]: http://en.wikipedia.org/wiki/Behavior_Driven_Development
[Jasmine]: https://github.com/pivotal/jasmine
[node.js]: http://nodejs.org/
[Jasmine-Node]: https://github.com/mhevery/jasmine-node
[CoffeeScript]: http://jashkenas.github.com/coffee-script/
[test framework]: http://en.wikipedia.org/wiki/Test_automation_framework
[Rake]: http://rake.rubyforge.org/
[make]: http://www.gnu.org/software/make/
[Ruby]: http://www.ruby-lang.org/
[Rails]: http://www.rubyonrails.org/
[Django]: http://www.djangoproject.com/
