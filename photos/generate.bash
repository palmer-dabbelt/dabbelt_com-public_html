#!/bin/bash

outdir="$(readlink -f "$1")"
indir="$(readlink -f "$2")"
conf="$indir"/photorc

# Clean the output directory in case any extra files still exist
#rm -rf "$outdir"
mkdir -p "$outdir"

# Start an empty makefile
mf="$outdir/Makefile"
echo ".PHONY: all" > "$mf"
echo "all:" >> "$mf"

# Generate the thumbnails and rotated images
cd "$indir"
find * -iname "*.jpeg" -print0 | sort -z | while read -d $'\0' file
do
    # Private files should just be straight-out skipped
    if [[ "$(grep "^PRIVATE $file$" "$conf" | wc -l)" != "0" ]]
    then
	continue
    fi

    # Ensures the output directory exists
    mkdir -p "$outdir"/"$file"

    # Generate the thumbnail
    if="$indir/$file"
    of="$outdir/$file/thumb.jpeg"
    echo "all: $of" >> "$mf"
    echo "$of: $if" >> "$mf"
    echo -e "\tconvert -geometry 200x150 $if $of" >> "$mf"
    echo "" >> "$mf"

    # And generate the full file
    if="$indir/$file"
    of="$outdir/$file/full.jpeg"
    echo "all: $of" >> "$mf"
    echo "$of: $if" >> "$mf"
    echo -e "\tconvert -geometry 1200x900 $if $of" >> "$mf"
    echo "" >> "$mf"
done

# Generate the index file
title=""
if [[ "$(grep "^TITLE " "$conf" | wc -l)" != "0" ]]
then
    title=": $(grep "^TITLE " "$conf" | cut -d' ' -f2-)"
fi

cd "$indir"
cat >"$outdir"/index.html <<EOF
<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Photo Album$title</title>
  </head>

  <body>
    <p>
    <table width="100%" border="0" cellpadding="0">
      <tr>
EOF

cd "$indir"
col="0"
find * -iname "*.jpeg" -print0 | sort -z | while read -d $'\0' file
do
    # Private files should just be straight-out skipped
    if [[ "$(grep "^PRIVATE $file$" "$conf" | wc -l)" != "0" ]]
    then
	continue
    fi

    tf="$outdir/$file/thumb.jpeg"
    ff="$outdir/$file/full.jpeg"

    # Sometimes generates a table break
    if [[ "$col" == "5" ]]
    then
	col="0"
	echo "</tr><tr>" >> "$outdir"/index.html
    fi

    echo "<td width=\"20%\">" >> "$outdir"/index.html
    echo "<a href=\"$ff\"><img src=\"$tf\" width=\"100%\"></img></a>" \
	>> "$outdir"/index.html
    echo "</td>" >> "$outdir"/index.html

    col="$(($col + 1))"
done

cat >>"$outdir"/index.html <<EOF
      </tr>
    </table>
    </p>
  </body>
</html>
EOF
