#!/bin/sh -e
wd="$1"
if [ -z $1 ]
then
	echo "Usage: $0 [path-to-code]"
	exit 1
fi

if [ ! -e $1 ]
then
	echo "Error: checking out code is not yet supported"
	exit 2
fi

cd "$1"
git fetch --all
git reset --hard origin/master
