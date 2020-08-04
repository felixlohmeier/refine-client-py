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

# =================================== DATA =================================== #

cat << "DATA" > "tmp/${t}/${t}.xml"
<?xml version="1.0" encoding="UTF-8"?>
<root>
  <record>
    <icon>⛲</icon>
    <code>1F347</code>
    <meaning>FOUNTAIN</meaning>
  </record>
  <record>
    <icon>⛳</icon>
    <code>1F349</code>
    <meaning>FLAG IN HOLE</meaning>
  </record>
  <record>
    <icon>⛵</icon>
    <code>1F352</code>
    <meaning>SAILBOAT</meaning>
  </record>
</root>
DATA

cat << "DATA" > "tmp/${t}/${t}.transform"
[
  {
    "op": "core/column-removal",
    "columnName": "root"
  },
  {
    "op": "core/column-removal",
    "columnName": "root - record"
  },
  {
    "op": "core/row-removal",
    "engineConfig": {
      "facets": [
        {
          "type": "list",
          "name": "Blank Rows",
          "expression": "(filter(row.columnNames,cn,isNonBlank(cells[cn].value)).length()==0).toString()",
          "columnName": "",
          "invert": false,
          "omitBlank": false,
          "omitError": false,
          "selection": [
            {
              "v": {
                "v": "true",
                "l": "true"
              }
            }
          ],
          "selectBlank": false,
          "selectError": false
        }
      ],
      "mode": "record-based"
    }
  }
]
DATA

# ================================= ASSERTION ================================ #

cat << "DATA" > "tmp/${t}/${t}.assert"
root - record - icon	root - record - code	root - record - meaning
⛲	1F347	FOUNTAIN
⛳	1F349	FLAG IN HOLE
⛵	1F352	SAILBOAT
DATA

# ================================== ACTION ================================== #

${cmd} --create "tmp/${t}/${t}.xml"
${cmd} --apply "tmp/${t}/${t}.transform" "${t}"
${cmd} --export "${t}" --output "tmp/${t}/${t}.output"

# =================================== TEST =================================== #

diff -u "tmp/${t}/${t}.assert" "tmp/${t}/${t}.output"
