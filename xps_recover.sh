#!/bin/bash

HOST="localhost:50101"
TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

SELF=$(basename "${0}");

if [ "${#}" -ne 1 ]; then
    echo "usage: ${SELF} [filename]"
    exit -1
fi

raise () { cat - 1>&2; }

INPUT="${1}.0"
rm -f "${INPUT}" 2> /dev/null
cat "${1}" | grep -v "DEV@" | grep -v "@query" > "${INPUT}"

while read -r line; do
    head=$(printf "%s" "${line}" | cut -d' ' -f1-4)
    content=$(printf "%s" "${line}" | cut -d' ' -f7- | cut -c9-)
    payload=$(printf "%s" "${content}")
    [[ "${line}" =~ ^#.* ]] && continue
    curl -s -d "${payload}" -X POST -H "Content-Type: application/json" -H "Authorization: Token ${TOKEN}" "${HOST}" && printf "%s\n" " <- ${head}" | cut -c1-80
done < "${INPUT}"

tail -n1 "${INPUT}" | cut -c1-100
lines=$(cat "${INPUT}" | wc -l)
echo "${lines}"

lines=$((lines + 1))

rm "${1}.1" 2> /dev/null
cat "${1}" | tail -n +"${lines}" > "${1}.1"