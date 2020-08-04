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

# ================================== ACTION ================================== #

${cmd} --download "https://git.io/fj5ju" --output "tmp/${t}/${t}.output"

# =================================== TEST =================================== #

diff -u "data/duplicates-deletion.json" "tmp/${t}/${t}.output"
