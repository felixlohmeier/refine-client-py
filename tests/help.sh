#!/bin/bash

# =============================== ENVIRONMENT ================================ #

if [[ ${1} ]]; then
  cmd="${1}"
else
  echo 1>&2 "execute tests.sh to run all tests"; exit 1
fi

t="$(basename "${BASH_SOURCE[0]}" .sh)"
cd "${BASH_SOURCE%/*}/" || exit 1
mkdir -p "tmp/${t}"

# ================================= ASSERTION ================================ #

cat << "DATA" > "tmp/${t}/${t}.assert"
Usage: refine.py [--help | OPTIONS]

Script to provide a command line interface to an OpenRefine server.

Options:
  -h, --help            show this help message and exit

  Connection options:
    -H 127.0.0.1, --host=127.0.0.1
                        OpenRefine hostname (default: 127.0.0.1)
    -P 3333, --port=3333
                        OpenRefine port (default: 3333)

  Commands:
    -c [FILE], --create=[FILE]
                        Create project from file. The filename ending (e.g.
                        .csv) defines the input format
                        (csv,tsv,xml,json,txt,xls,xlsx,ods)
    -l, --list          List projects
    --download=[URL]    Download file from URL (e.g. example data). Combine
                        with --output to specify a filename.

  Commands with argument [PROJECTID/PROJECTNAME]:
    -d, --delete        Delete project
    -f [FILE], --apply=[FILE]
                        Apply JSON rules to OpenRefine project
    -E, --export        Export project in tsv format to stdout.
    -o [FILE], --output=[FILE]
                        Export project to file. The filename ending (e.g.
                        .tsv) defines the output format
                        (csv,tsv,xls,xlsx,html)
    --template=[STRING]
                        Export project with templating. Provide (big) text
                        string that you enter in the *row template* textfield
                        in the export/templating menu in the browser app)
    --info              show project metadata

  General options:
    --format=FILE_FORMAT
                        Override file detection (import:
                        csv,tsv,xml,json,line-based,fixed-width,xls,xlsx,ods;
                        export: csv,tsv,html,xls,xlsx,ods)

  Create options:
    --columnWidths=COLUMNWIDTHS
                        (txt/fixed-width), please provide widths in multiple
                        arguments, e.g. --columnWidths=7 --columnWidths=5
    --encoding=ENCODING
                        (csv,tsv,txt), please provide short encoding name
                        (e.g. UTF-8)
    --guessCellValueTypes=true/false
                        (xml,csv,tsv,txt,json, default: false)
    --headerLines=HEADERLINES
                        (csv,tsv,txt/fixed-width,xls,xlsx,ods), default: 1,
                        default txt/fixed-width: 0
    --ignoreLines=IGNORELINES
                        (csv,tsv,txt,xls,xlsx,ods), default: -1
    --includeFileSources=true/false
                        (all formats), default: false
    --limit=LIMIT       (all formats), default: -1
    --linesPerRow=LINESPERROW
                        (txt/line-based), default: 1
    --processQuotes=true/false
                        (csv,tsv), default: true
    --projectName=PROJECTNAME
                        (all formats), default: filename
    --projectTags=PROJECTTAGS
                        (all formats), please provide tags in multiple
                        arguments, e.g. --projectTags=beta
                        --projectTags=client1
    --recordPath=RECORDPATH
                        (xml,json), please provide path in multiple arguments,
                        e.g. /collection/record/ should be entered:
                        --recordPath=collection --recordPath=record, default
                        xml: root element, default json: _ _
    --separator=SEPARATOR
                        (csv,tsv), default csv: , default tsv: \t
    --sheets=SHEETS     (xls,xlsx,ods), please provide sheets in multiple
                        arguments, e.g. --sheets=0 --sheets=1, default: 0
                        (first sheet)
    --skipDataLines=SKIPDATALINES
                        (csv,tsv,txt,xls,xlsx,ods), default: 0, default line-
                        based: -1
    --storeBlankCellsAsNulls=true/false
                        (csv,tsv,txt,xls,xlsx,ods), default: true
    --storeBlankRows=true/false
                        (csv,tsv,txt,xls,xlsx,ods), default: true
    --storeEmptyStrings=true/false
                        (xml,json), default: true
    --trimStrings=true/false
                        (xml,json), default: false

  Templating options:
    --mode=row-based/record-based
                        engine mode (default: row-based)
    --prefix=PREFIX     text string that you enter in the *prefix* textfield
                        in the browser app
    --rowSeparator=ROWSEPARATOR
                        text string that you enter in the *row separator*
                        textfield in the browser app
    --suffix=SUFFIX     text string that you enter in the *suffix* textfield
                        in the browser app
    --filterQuery=REGEX
                        Simple RegEx text filter on filterColumn, e.g. ^12015$
    --filterColumn=COLUMNNAME
                        column name for filterQuery (default: name of first
                        column)
    --facets=FACETS     facets config in json format (may be extracted with
                        browser dev tools in browser app)
    --splitToFiles=true/false
                        will split each row/record into a single file; it
                        specifies a presumably unique character series for
                        splitting; --prefix and --suffix will be applied to
                        all files; filename-prefix can be specified with
                        --output (default: %Y%m%d)
    --suffixById=true/false
                        enhancement option for --splitToFiles; will generate
                        filename-suffix from values in key column

Example data:
  --download "https://git.io/fj5hF" --output=duplicates.csv
  --download "https://git.io/fj5ju" --output=duplicates-deletion.json

Basic commands:
  --list # list all projects
  --list -H 127.0.0.1 -P 80 # specify hostname and port
  --create duplicates.csv # create new project from file
  --info "duplicates" # show project metadata
  --apply duplicates-deletion.json "duplicates" # apply rules in file to project
  --export "duplicates" # export project to terminal in tsv format
  --export --output=deduped.xls "duplicates" # export project to file in xls format
  --delete "duplicates" # delete project

Some more examples:
  --info 1234567890123 # specify project by id
  --create example.tsv --encoding=UTF-8
  --create example.xml --recordPath=collection --recordPath=record
  --create example.json --recordPath=_ --recordPath=_
  --create example.xlsx --sheets=0
  --create example.ods --sheets=0

Example for Templating Export:
  Cf. https://github.com/opencultureconsulting/openrefine-client#advanced-templating
DATA

# ================================== ACTION ================================== #

${cmd} --help > "tmp/${t}/${t}.output"

# =================================== TEST =================================== #

diff -u "tmp/${t}/${t}.assert" "tmp/${t}/${t}.output"
