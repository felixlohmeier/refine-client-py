#!/bin/bash

# =============================== ENVIRONMENT ================================ #

t="create-csv"

cd "${BASH_SOURCE%/*}/" || exit 1
client="python3 ../refine.py -H localhost -P 3334"
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
a	b	c
1	2	3
0	0	0
$	\	'
DATA

# ================================== ACTION ================================== #

${client} --create "tmp/${t}/${t}.csv"
${client} --export "${t}" --output "tmp/${t}/${t}.output"

# =================================== TEST =================================== #

diff -u "tmp/${t}/${t}.assert" "tmp/${t}/${t}.output"
