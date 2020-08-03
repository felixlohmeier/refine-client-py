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

cat << "DATA" > "tmp/${t}/${t}.csv"
a,b,c
1,2,3
0,0,0
$,\,'
DATA

cat << "DATA" > "tmp/${t}/${t}.transform"
[
  {
    "op": "core/column-addition",
    "engineConfig": {
      "mode": "row-based"
    },
    "newColumnName": "apply",
    "columnInsertIndex": 2,
    "baseColumnName": "b",
    "expression": "grel:value.replace('2','٩(͡๏̯͡๏)۶')",
    "onError": "set-to-blank"
  }
]
DATA

# ================================= ASSERTION ================================ #

cat << "DATA" > "tmp/${t}/${t}.assert"
a	b	apply	c
1	2	٩(͡๏̯͡๏)۶	3
0	0	0	0
$	\	\	'
DATA

# ================================== ACTION ================================== #

${cmd} --create "tmp/${t}/${t}.csv"
${cmd} --apply "tmp/${t}/${t}.transform" "${t}"
${cmd} --export "${t}" --output "tmp/${t}/${t}.output"

# =================================== TEST =================================== #

diff -u "tmp/${t}/${t}.assert" "tmp/${t}/${t}.output"
