#!/bin/sh
dbfile=bitmarks.db

url=$(echo 'SELECT url FROM marks WHERE assigned=0 LIMIT 1;' | sqlite3 "${dbfile}")
if [ -z "${url}" ]
then
	echo "URLs exhausted" 2>&2
	exit 1
fi
echo "UPDATE marks SET assigned=1 WHERE url='${url}';" | sqlite3 "${dbfile}"
echo "${url}"
