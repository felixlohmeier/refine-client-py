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
DATA

# ================================= ASSERTION ================================ #

cat << DATA > "tmp/${t}/${t}.assert"
DATA

# ================================== ACTION ================================== #

${cmd} --create "tmp/${t}/${t}.csv"
${cmd} --delete "${t}"
${cmd} --list | grep "${t}" | cut -d ':' -f 2 > "tmp/${t}/${t}.output"

# =================================== TEST =================================== #

diff -u "tmp/${t}/${t}.assert" "tmp/${t}/${t}.output"
