"""
Installs the most efficient reactor for the platform. Import this module
before importing reactor. e.g.::

    from invitemedia.library.twisted.internet import ReactorFinder
    from twisted.internet import reactor
"""
import exceptions
import os
import sys

reactorchoices = ["epollreactor",
                  "kqreactor",
                  "cfreactor",
                  "win32eventreactor",
                  "iocpreactor",
                  "pollreactor",
                  "selectreactor",
                  "posixbase",
                  "default"]

try:
    preferred = os.environ['TWISTED_REACTOR']
    if len(preferred) > 0:
        reactorchoices = [preferred] + reactorchoices
except KeyError:
    pass

_installed = False

if not _installed:
    for choice in reactorchoices:
        try:
            exec("from twisted.internet import %s as bestreactor" % choice)
            break
        except exceptions.Exception, err:
            print err

    try:
        bestreactor.install()
        _installed = True

    except AssertionError:
        _installed = True

    except Exception, ex:
        print sys.exc_info()
        print 'Unable to find reactor "%s": %s.\nExiting...' % (choice, str(ex))
        sys.exit(1)
