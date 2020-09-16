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
email,name,state,gender,purchase
arthur.duff@example4.com,Arthur Duff,OR,M,Dining table
,Arthur Duff,OR,M,Night table
ben.morisson@example6.org,Ben Morisson,FL,M,Amplifier
ben.tyler@example3.org,Ben Tyler,NV,M,Flashlight
danny.baron@example1.com,Daniel Baron,CA,M,Bike
,Danny Baron,CA,M,TV
,D. Baron,CA,M,Winter jacket
jean.griffith@example5.org,Jean Griffith,WA,F,Power drill
melanie.white@example2.edu,Melanie White,NC,F,iPad
,Melanie White,NC,F,iPhone
DATA

# ================================= ASSERTION ================================ #

cat << "DATA" > "tmp/${t}/${t}.assert"
{ "events" : [
    { "name" : "Melanie White", "purchase" : "iPad" }    { "name" : "Melanie White", "purchase" : "iPhone" }
] }
DATA

# ================================== ACTION ================================== #

${cmd} --create "tmp/${t}/${t}.csv"
${cmd} --export "${t}" \
--prefix '{ "events" : [
' \
--template '    { "name" : {{jsonize(cells["name"].value)}}, "purchase" : {{jsonize(cells["purchase"].value)}} }' \
--rowSeparator ',
' \
--suffix '
] }
' \
--mode "record-based" \
--splitToFiles true \
--output "tmp/${t}/${t}.output"

# =================================== TEST =================================== #

ls "tmp/${t}"
diff -u "tmp/${t}/${t}.assert" "tmp/${t}/${t}_6.output"
