#!/bin/bash
# Script for running functional tests against the CLI

# Copyright (c) 2011 Paul Makepeace, Real Programmers. All rights reserved.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>

# ================================== CONFIG ================================== #

cd "${BASH_SOURCE%/*}/" || exit 1

port=3334

if [[ ${1} ]]; then
  version="${1}"
else
  version="3.2"
fi
refine="openrefine-${version}/refine"

if [[ ${2} ]]; then
  client="$(readlink -e "${2}")"
else
  client="python3 $(readlink -e refine.py)"
fi
cmd="${client} -H localhost -P ${port}"

# =============================== REQUIREMENTS =============================== #

# check existence of java and cURL
if [[ -z "$(command -v java 2> /dev/null)" ]] ; then
  echo 1>&2 "ERROR: OpenRefine requires JAVA runtime environment (jre)" \
    "https://openjdk.java.net/install/"
  exit 1
fi
if [[ -z "$(command -v curl 2> /dev/null)" ]] ; then
  echo 1>&2 "ERROR: This shell script requires cURL" \
    "https://curl.haxx.se/download.html"
  exit 1
fi
# download OpenRefine
if [[ -z "$(readlink -e "${refine}")" ]]; then
  echo "Download OpenRefine..."
  mkdir -p "$(dirname "${refine}")"
  curl -L --output openrefine.tar.gz \
    "https://github.com/OpenRefine/OpenRefine/releases/download/${version}/openrefine-linux-${version}.tar.gz"
  echo "Install OpenRefine in subdirectory $(dirname "${refine}")..."
  tar -xzf openrefine.tar.gz -C "$(dirname "${refine}")" --strip 1 --totals
  rm -f openrefine.tar.gz
  # do not try to open OpenRefine in browser
  sed -i '$ a JAVA_OPTIONS=-Drefine.headless=true' \
    "$(dirname "${refine}")"/refine.ini
  # set autosave period from 5 minutes to 25 hours
  sed -i 's/#REFINE_AUTOSAVE_PERIOD=60/REFINE_AUTOSAVE_PERIOD=1500/' \
    "$(dirname "${refine}")"/refine.ini
  echo
fi

# ================================== SETUP =================================== #

dir="$(readlink -f "tests/tmp")"
mkdir -p "${dir}"
rm -f tests.log

echo "start OpenRefine server..."
${refine} -v warn -p ${port} -d "${dir}" &>> tests.log &
pid_server=${!}
timeout 30s bash -c "until curl -s 'http://localhost:3334' \
  | cat | grep -q -o 'OpenRefine' ; do sleep 1; done" \
  || error "starting OpenRefine server failed!"
echo

# ================================== TESTS =================================== #

echo "running tests, please wait..."
tests=()
results=()
for t in tests/*.sh; do
  tests+=("${t}")
  echo "========================= ${t} =========================" &>> tests.log
  bash ${t} "${cmd}" "${version}" &>> tests.log
  results+=(${?})
done
echo

# ================================= TEARDOWN ================================= #

echo "cleanup..."
{ kill -9 "${pid_server}" && wait "${pid_server}"; } 2>/dev/null
rm -rf "${dir}"
echo

# ================================= SUMMARY ================================== #

printf "%s\t%s\n" "code" "test"
printf "%s\t%s\n" "----" "----------------"
for i in "${!tests[@]}"; do
  printf "%s\t%s\n" "${results[$i]}" "${tests[$i]}"
done
echo
if [[ " ${results[*]} " =~ [1-9] ]]; then
  echo "failed tests! check tests.log for debugging"; echo
else
  echo "all tests passed!"; echo
fi
