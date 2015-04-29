#!/bin/sh -e
#

if [ -z "$1" ]; then
   echo "error : you must supply a branch name."
   exit 1
fi

BRANCH=$1

git clone /origin/. -b $BRANCH
git submodule init
git submodule update

if [ "$2" = "skipTests" ]; then
   mvn clean install -DskipTests
else
   mvn clean install
fi
