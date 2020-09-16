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
Script to provide a command line interface to an OpenRefine server.
DATA

# ================================== ACTION ================================== #

${cmd} --help | sed '3q;d' > "tmp/${t}/${t}.output"

# =================================== TEST =================================== #

diff -u "tmp/${t}/${t}.assert" "tmp/${t}/${t}.output"
