---
title: Quick Fix for UTF-8 CSV files in Microsoft Excel
tags:
    - excel
    - macos
categories:
    - devops
---

One of our most requested features in our systems is to allow the end-user to download data "for Excel", and our simplest solution is to generate a downloadable CSV file. Since we're in 2020, our stack is UTF-8 by default, which means that whenever we generate a CSV file we automatically encode it as UTF-8. This in turn generates the most common complaint: "the data looks weird in Excel".

If you've had any experience with Excel at all, you might have guessed that the issue lies in the file encoding interpretation. I'm not sure how/if Excel handles encoding detection, but I'm certain there are a lot of legacy reasons and backwards compatibility requirements that would explain this. The thing is, it never defaults to UTF-8 when opening CSV files, which raises complaints with our users.

Excel looks for a special signature string at the beginning of a CSV file to determine its encoding. For UTF-8 we can add 3 special bytes to _hint_ the UTF-8 signature (the signature is a type of "BOM" for Byte Order Mark), the actual bytes are: `\xEF\xBB\xBF`.  So the solution to this problem is very simple: add those 3 bytes at the beginning of the CSV file. (Also, remember to _remove_ the bytes before parsing the file into a script.)

Anyway, just prefix those 3 bytes in your content before generating the downloadable file and you're done.

If you are working with an existent file, this can be done as a shell one-liner:

```bash
$> echo -ne "\xEF\xBB\xBF" | cat - myfile.csv > myfile-utf8bom.csv
```

Since this is a common occurrence in our data handling activities, I frequently have to google the correct bash options required to prefix a non-ASCII string to a file. I wrote a tiny script that I've placed in my local `PATH` to invoke this one-liner whenever I need it.

Here's the script:

```bash
#!/bin/bash

# Microsoft Excel looks for a special UTF-8 signature "BOM" string at the beginning of a CSV file to determine its encoding
# This command prepends the special "\xEF\xBB\xBF" string to a CSV file

# In macOS, place this file inside your /usr/local/bin directory, and name it 'add-xls-utf8-bom'

if [ "$1" == "" ]; then
    echo "add-xls-utf8-bom [input file] [output file]"
    echo "missing input file"
    exit 1
fi

if [ "$2" == "" ]; then
    echo "add-xls-utf8-bom [input file] [output file]"
    echo "missing output file"
    exit 1
fi

# the actual one-liner to prepend the characters
echo -ne "\xEF\xBB\xBF" | cat - $1 > $2
```

In macOS, create a new file inside the directory `/usr/local/bin` and give it execute (`+x`) permissions.

```bash
$> nano /usr/local/bin/add-xls-utf8-bom
$> chmod +x /usr/local/bin/add-xls-utf8-bom
```

Then use it as:

```bash
$> add-xls-utf8-bom myfile.csv myfile-utf8bom.csv
```

Nifty.