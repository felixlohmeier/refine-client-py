#!/bin/bash

# =============================== ENVIRONMENT ================================ #

if [[ ${1} ]]; then
  cmd="${1}"
else
  echo 1>&2 "execute tests.sh to run all tests"; exit 1
fi
if [[ -z "$(command -v ssconvert 2> /dev/null)" ]] ; then
  echo 1>&2 "ERROR: This test requires ssconvert (gnumeric)"
  exit 127
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

# ================================= ASSERTION ================================ #

cat << "DATA" > "tmp/${t}/${t}.assert"
a,b,c
1,2,3
0,0,0
$,\,'
DATA

# ================================== ACTION ================================== #

${cmd} --create "tmp/${t}/${t}.csv"
${cmd} --export "${t}" --output "tmp/${t}/${t}.ods"
(cd tmp/"${t}" &&
  ssconvert -S "${t}.ods" "${t}.csv" &&
  mv "${t}.csv.1" "${t}.output")

# =================================== TEST =================================== #

diff -u "tmp/${t}/${t}.assert" "tmp/${t}/${t}.output"
