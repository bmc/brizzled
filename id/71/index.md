---
layout: article
tags: python, programming
title: Python, sys.path and EasyInstall, programming
date: 2008-03-18 00:00:00
toc: toc
---

# The Problem

At work, I'm wrapping up a script that does a custom install of a
whole bunch of software. We decided to install our stuff in a
[virtual Python environment][],
which provides several advantages that aren't especially germane to
this article. What *is* germane is that the installation script
must use the `virtualenv` package, but it cannot assume that the
`virtualenv` package has been installed.

This [chicken and egg][] problem is easily managed by adding a "bootstrap"
phase to the installation module. It works something like this:

    # create a temporary directory
    
    import tempfile
    bootstrapDir = tempfile.mkdtemp()
    
    # Get and create the 'site-packages' directory
    versionInfo = sys.version_info
    sitePackagesDir = os.path.join(dir,
                                   'lib',
                                   'python%d.%d' % (versionInfo[0], versionInfo[1]),
                                   'site-packages')
    os.makedirs(path, 0755)
    
    installBootstrapPackages(bootstrapDir) # left as exercise to reader
    
    # Make sure Python can find the newly installed package
    
    sys.path += [sitePackagesDir]

In theory, this should work. In fact, if the dynamically installed
software resides in standard Python packages or modules, it *will*
work. However, it failed for me with `virtualenv`. My attempt to
import `virtualenv` failed with an `ImportError`. After some
head-scratching, some
[Googling][]
and some [UTSL][]'ing, the
solution became clear.

The problem is that
[EasyInstall][]
(which is what I'm using to install `virtualenv`) creates a
`virtualenv-1.0-py2.5.egg` directory in my temporary
`site-packages` directory. However, Python doesn't automatically
know to search the `virtualenv-1.0-py25.egg` directory, so
EasyInstall puts that directory's name in a special `.pth` file in
`site-packages`. Normally, that's enough; Python will read all the
`.pth` files it finds and add them to `sys.path`.

*However*... It only reads `.pth` files at startup. Adding a
directory to `sys.path` does *not* cause Python to re-read the
`.pth` files.

# A Solution

Fortunately, there's a simple solution: Replace:

    sys.path += [sitePackagesDir]

with

    import site
    site.addsitedir(sitePackagesDir)

The `site` module contains the logic that Python invokes, at
startup, to set `sys.path`, and it reads the `.pth` files. Calling
`site.addsitedir()` directly forces Python to re-read all those
`.pth` files.

If there's a more appropriate way to accomplish this task, I'd love
to hear about it. Meanwhile, this solution seems to get the job
done.

# Feedback

## 20 August, 2008

On [Reddit][], a user named **oblivion95**
[writes][]:

> I was just asking about a related problem on a newsgroup. All you
> have to do is:
> 
>     sys.path.append(my_egg_dir)
>     from pkg_resources import require
>     require("virtualenv")
>     ...
>     import virtualenv
> 
> This might seem like extra work, but the require() actually allows
> you to specify a range of versions. That is quite a benefit.
> 
> And by the way, you can use the -m option to `easy_install` if you
> want to avoid the `.pth` and `site.py` complexity altogether. Just
> use `require()` for all modules that are in eggs.

[virtual Python environment]: http://pypi.python.org/pypi/virtualenv
[chicken and egg]: http://en.wikipedia.org/wiki/Chicken-and-egg_problem%22&gt;chicken%20and%20egg%20problem
[Googling]: http://www.velocityreviews.com/forums/t342912-pth-files.html
[UTSL]: http://www.jargondb.org/glossary/utsl
[EasyInstall]: http://peak.telecommunity.com/DevCenter/EasyInstall
[Reddit]: http://www.reddit.com/
[writes]: http://www.reddit.com/r/python/comments/6vri8/python_syspath_and_easyinstall/
