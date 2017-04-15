#!/bin/sh
dbfile=bitmarks.db

echo 'DROP TABLE IF EXISTS marks; CREATE TABLE marks (url string NOT NULL PRIMARY KEY UNIQUE, assigned bool NOT NULL DEFAULT 0);' | sqlite3 ${dbfile}

cat 500-URLS.text | xargs -I % echo "INSERT INTO marks (url, assigned) VALUES ('"%"', 0);" | sqlite3 ${dbfile}
