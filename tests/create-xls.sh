#!/bin/bash

# =============================== ENVIRONMENT ================================ #

if [[ ${1} ]]; then
  cmd="${1}"
else
  echo 1>&2 "execute tests.sh to run all tests"; exit 1
fi
if [[ ${2} ]]; then
  version="${2}"
fi

t="$(basename "${BASH_SOURCE[0]}" .sh)"
cd "${BASH_SOURCE%/*}/" || exit 1
mkdir -p "tmp/${t}"

# =================================== DATA =================================== #

cp "data/example.xls" "tmp/${t}/${t}.xls"
#a	b	c
#1	2	3
#0	0	0
#$	\	'

# ================================= ASSERTION ================================ #

if [[ "${version}" = "2.7" ]]; then
  cat << "DATA" > "tmp/${t}/${t}.assert"
a	b	c
1.0	2.0	3.0
0.0	0.0	0.0
$	\	'
DATA
else
  #TODO
  echo "https://github.com/opencultureconsulting/openrefine-client/issues/4"
  exit 200
fi

# ================================== ACTION ================================== #

${cmd} --create "tmp/${t}/${t}.xls"
${cmd} --export "${t}" --output "tmp/${t}/${t}.output"

# =================================== TEST =================================== #

diff -u "tmp/${t}/${t}.assert" "tmp/${t}/${t}.output"
