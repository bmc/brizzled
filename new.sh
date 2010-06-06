#!//usr/bin/env bash

id=${1?'Missing ID (first argument)'}
dir=$(cd $(dirname $0); pwd)

for i in $id.textile $id.md
do
    if [ -f $dir/id/$i ]
    then
        echo "$dir/id/$i already exists." >&2
        exit 1
    fi
done

cat <<EOF1 >$dir/id/$id.md
{{
page.templates: article=%s.html, printable-article=%spr.html
page.title: Title
page.tags: Tags
---
Description goes here
}}

Content goes here
EOF1

echo "Created $dir/id/$id.md"
