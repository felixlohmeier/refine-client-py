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

cat << "DATA" > "tmp/${t}/${t}.tsv"
🔣	code	meaning
🍇	1F347	GRAPES
🍉	1F349	WATERMELON
🍒	1F352	CHERRIES
🍓	1F353	STRAWBERRY
🍍	1F34D	PINEAPPLE
DATA

# ================================= ASSERTION ================================ #

cat << DATA > "tmp/${t}/${t}.assert"
          column 001: 🔣
DATA

# ================================== ACTION ================================== #

${cmd} --create "tmp/${t}/${t}.tsv"
${cmd} --info "${t}" | grep 'column 001' > "tmp/${t}/${t}.output"

# =================================== TEST =================================== #

diff -u "tmp/${t}/${t}.assert" "tmp/${t}/${t}.output"
