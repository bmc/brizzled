---
layout: post
title: "Hacking Buildr's POM Generation"
date: 2012-03-31 19:41
comments: true
categories: [ruby, buildr, java, maven]
---

Awhile ago, I finally decided to bring the build process for one of my open source
Java projects [into the 21st century][]. Since I find Maven irritating, I
converted the project to use [Buildr][], a [Rake][]-based build tool that
contains, among other things, Maven-style dependency management.

Life was good. I had a nice, simple build, with all the power of Ruby at my
disposal, and without any need to edit XML, which [sucks][].

Then, someone reported a [bug][]: The Buildr-generated POM did not contain
dependencies. As the author of the bug report wrote:

{% blockquote %}
Maybe they should be added to the POM, so my build system (I use Gradle) will be able to download all the required jars?
{% endblockquote %}

That, of course, is a perfectly reasonable request. As it happens, it was 
easier requested than accomplished.

<!-- more -->

After digging through numerous search results, as well as the Buildr source
code, I finally came up with a solution. It's a hack, requiring some local
metaprogramming of Buildr's Ruby code--a solution that is subject to breakage,
when subsequent versions of Buildr are released.

But, for now, it gets the job done.

The first step was to install the `buildr-resolver` gem. I chose to do that via
[Bundler][]. That way, the `Gemfile` becomes a manifest of all the third-party
gems my build requires.

{% codeblock Gemfile lang:ruby %}
source 'http://rubygems.org'

gem 'buildr-resolver'
{% endcodeblock %}

The next step was to define some simple constants, at the top of my Buildr
`Buildfile`:

{% codeblock Buildfile excerpt lang:ruby %}
# Name of the project, for easy substitution.
PROJECT          = 'javautil'

# The artifacts I depend on.
JAVAX            = 'javax.activation:activation:jar:1.1-rev-1'
JAVAMAIL         = 'javax.mail:mail:jar:1.4.4'
ASM              = 'asm:asm:jar:3.3.1'
ASM_COMMONS      = 'asm:asm-commons:jar:3.3.1'
COMMONS_LOGGING  = 'commons-logging:commons-logging:jar:1.1.1'
SLF4J            = 'org.slf4j:slf4j-jdk14:jar:1.6.4'

# All artifacts, as a single Ruby array
DEPS             = [JAVAX, JAVAMAIL, ASM, ASM_COMMONS, COMMONS_LOGGING]

# The project version. In most builds, this could be a simple constant. In
# my case, it's stored in a Java properties file, deep in the source. The code,
# below, extracts the version number from the properties file.
MAIN_BUNDLE      = 'src/main/resources/org/clapper/util/misc/Bundle.properties'
VERSION          = File.open(MAIN_BUNDLE) do |f|
  f.readlines.select {|s| s =~ /^api\.version/}.map {|s| s.chomp.sub(/^.*=/, '')}
end[0]

# The location of the POM. This duplicates the name Buildr generates, so it's
# an unclean coupling.
THIS_POM         = "target/#{PROJECT}-#{VERSION}.pom"

# My artifact.
ARTIFACT         = "org.clapper:#{PROJECT}:jar:#{VERSION}"
{% endcodeblock %}

Next, I created a small utility method that uses `buildr-resolver` to write
the POM:

{% codeblock make_pom function lang:ruby %}
# Create a POM that has dependencies in it. Uses the buildr/resolver gem.
def make_pom
  mkdir_p File.dirname(THIS_POM)
  deps = Buildr::Resolver.resolve(DEPS)
  Buildr::Resolver.write_pom(ARTIFACT, THIS_POM)
end
{% endcodeblock %}

With those constants in place, it was time for some [monkey patching][]. I
tossed this hackery, as well as `make_pom`, at the bottom of my `Buildfile`,
where it's out of the way. Someday, I might get ambitious and put it in a gem.

The first patch, to `Buildr::Package`, replaces the stock
`Buildr::Package.package` method to rebuild the POM after the regular Buildr
`package` function is run.

The second patch replaces Buildr's `ActsAsArtifact.pom_xml` method, which is
responsible for creating the XML for the POM. Ideally, I'd build the XML in-
memory, as the real `pom_xml` does, instead of building my POM file and reading
its contents into memory; as it happens, Buildr will take that in-memory
XML I give it and overwrite the POM I _just_ created. However,
`buildr-resolver`, and the `naether` gem it uses under the covers, want a file
path, so I can't substitute something like `StringIO`.

So, a double-write of the file, it is. I can live with that, since this
solution has the advantage of actually getting the job done.

{% codeblock Buildfile POM hack lang:ruby %}
module Buildr

  # Local hack job to override Buildr's default POM generation, to include
  # dependencies in the POM.

  module Package
    alias :old_package :package
    def package(*args)
      old_package *args
      make_pom
    end

  end

  module ActsAsArtifact

    def pom_xml
      make_pom
      File.open(THIS_POM).readlines.join('')
    end
  end
end
{% endcodeblock %}

If there's a cleaner, more reasonable way to get Buildr to produce a POM
that contains dependencies, I'd love to hear about it. In the meantime,
at least I was able to close the [bug][].

[javautil]: http://software.clapper.org/javautil/
[into the 21st century]: /blog/2011/09/17/why-i-dislike-maven/
[Buildr]: http://buildr.apache.org/
[Rake]: http://rake.rubyforge.org/
[sucks]: /blog/2011/09/17/why-i-dislike-maven/#xml-configuration-sucks
[bug]: https://github.com/bmc/javautil/issues/6
[Bundler]: http://gembundler.com/
[monkey patching]: http://en.wikipedia.org/wiki/Monkey_patch
