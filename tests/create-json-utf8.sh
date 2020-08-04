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

cat << "DATA" > "tmp/${t}/${t}.json"
[
  {
    "⌨": "⛲",
    "code": "1F347",
    "meaning": "FOUNTAIN"
  },
  {
    "⌨": "⛳",
    "code": "1F349",
    "meaning": "FLAG IN HOLE"
  },
  {
    "⌨": "⛵",
    "code": "1F352",
    "meaning": "SAILBOAT"
  }
]
DATA

# ================================= ASSERTION ================================ #

cat << "DATA" > "tmp/${t}/${t}.assert"
_ - ⌨	_ - code	_ - meaning
⛲	1F347	FOUNTAIN
⛳	1F349	FLAG IN HOLE
⛵	1F352	SAILBOAT
DATA

# ================================== ACTION ================================== #

${cmd} --create "tmp/${t}/${t}.json"
${cmd} --export "${t}" --output "tmp/${t}/${t}.output"

# =================================== TEST =================================== #

diff -u "tmp/${t}/${t}.assert" "tmp/${t}/${t}.output"
