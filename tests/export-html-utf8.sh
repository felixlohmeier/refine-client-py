#!/bin/bash

# =============================== ENVIRONMENT ================================ #

if [[ ${1} ]]; then
  cmd="${1}"
else
  echo 1>&2 "execute tests.sh to run all tests"; exit 1
fi
if [[ ${2} ]]; then
  majorversion="${2%%.*}"
fi

t="$(basename "${BASH_SOURCE[0]}" .sh)"
cd "${BASH_SOURCE%/*}/" || exit 1
mkdir -p "tmp/${t}"

# =================================== DATA =================================== #

cat << "DATA" > "tmp/${t}/${t}.csv"
⌨,code,meaning
⛲,1F347,FOUNTAIN
⛳,1F349,FLAG IN HOLE
⛵,1F352,SAILBOAT
DATA

# ================================= ASSERTION ================================ #

if [[ "$majorversion" = 2 ]]; then
  cat << "DATA" > "tmp/${t}/${t}.assert"
<html>
<head>
<title>export-html-utf8</title>
<meta charset="utf-8" />
</head>
<body>
<table>
<tr><th>⌨</th><th>code</th><th>meaning</th></tr>
<tr><td>&#9970;</td><td>1F347</td><td>FOUNTAIN</td></tr>
<tr><td>&#9971;</td><td>1F349</td><td>FLAG IN HOLE</td></tr>
<tr><td>&#9973;</td><td>1F352</td><td>SAILBOAT</td></tr>
</table>
</body>
</html>
DATA
else
  cat << "DATA" > "tmp/${t}/${t}.assert"
<html>
<head>
<title>export-html-utf8</title>
<meta charset="utf-8" />
</head>
<body>
<table>
<tr><th>⌨</th><th>code</th><th>meaning</th></tr>
<tr><td>⛲</td><td>1F347</td><td>FOUNTAIN</td></tr>
<tr><td>⛳</td><td>1F349</td><td>FLAG IN HOLE</td></tr>
<tr><td>⛵</td><td>1F352</td><td>SAILBOAT</td></tr>
</table>
</body>
</html>
DATA
fi

# ================================== ACTION ================================== #

${cmd} --create "tmp/${t}/${t}.csv"
${cmd} --export "${t}" --output "tmp/${t}/${t}.html"

# =================================== TEST =================================== #

diff -u "tmp/${t}/${t}.assert" "tmp/${t}/${t}.html"
