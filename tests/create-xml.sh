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
    <a>1</a>
    <b>2</b>
    <c>3</c>
  </record>
  <record>
    <a>0</a>
    <b>0</b>
    <c>0</c>
  </record>
  <record>
    <a>$</a>
    <b>\</b>
    <c>'</c>
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
root - record - a	root - record - b	root - record - c
1	2	3
0	0	0
$	\	'
DATA

# ================================== ACTION ================================== #

${cmd} --create "tmp/${t}/${t}.xml"
${cmd} --apply "tmp/${t}/${t}.transform" "${t}"
${cmd} --export "${t}" --output "tmp/${t}/${t}.output"

# =================================== TEST =================================== #

diff -u "tmp/${t}/${t}.assert" "tmp/${t}/${t}.output"
