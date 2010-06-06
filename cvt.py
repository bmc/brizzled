import csv
import os
import subprocess
import re
from StringIO import StringIO
import itertools

LINK = re.compile('^([^[]*)\[([^\]]+)\]\(([^)]+)\)')

def trim_blank_lines(lines):
    def lreverse(lines):
        l = []
        for i in range(len(lines) - 1, -1, -1):
            l.append(lines[i])
        return l
    def blank(line):
        return len(line.strip()) == 0
    def do_drop(lines):
        return [x for x in itertools.dropwhile(blank, lines)]

    return lreverse(do_drop(lreverse(do_drop(lines))))

def to_markdown(content):
    out = open("/tmp/foo.rst", "w")
    out.write(content)
    out.close()

    pandoc = "pandoc -f rst -t markdown /tmp/foo.rst"
    p = subprocess.Popen([pandoc], shell=True, stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, close_fds=True)
    md = []
    links=[]
    lines = p.stdout.readlines()

    for line in trim_blank_lines(lines):
        while True:
            m = LINK.search(line)
            if m == None:
                break
            line = m.group(1) + "[" + m.group(2) + "][]" + line[m.end(3) + 1:]
            links.append((m.group(2), m.group(3)))
        md.append(line)

    if len(links) > 0:
        md.append("\n")
        for (name, url) in links:
            md.append("[" + name + "]: " + url + "\n")

    return "".join(md)

reader = csv.reader(open("/Users/bmc/src/mystuff/python/blog/articles.csv"))
recnum = 0
try:
    for row in reader:
        recnum += 1

        id = row[0]
        desc=to_markdown(row[1])
        title=row[2]
        datetime=row[3].replace("T", " ")
        tags=eval(row[5])
        content=row[6]
        outPath = id + ".md"


        out = open(outPath, "w")
        out.write("""{{
page.templates: article=%s.html, printable-article=%spr.html
""")
        out.write("page.title: " + title + "\n")
        out.write("page.tags: " + ", ".join(tags) + "\n")
        out.write("page.date: " + datetime + "\n")
        out.write("---\n")
        out.write(desc + "}}\n\n")

        out.write(to_markdown(content))
        out.close()

        print("Wrote " + outPath)
except Exception, e:
    print("Error on input line " + str(recnum) + ": " + e.message)
    raise
