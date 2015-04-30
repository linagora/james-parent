#!/bin/sh -e
#

if [ -z "$1" ]; then
   echo "error : you must supply a branch name."
   exit 1
fi

BRANCH=$1
ORIGIN=/origin

git clone $ORIGIN/. -b $BRANCH
for i in `git submodule | cut -d' ' -f2`; do
   INITIALIZED=`cd $ORIGIN; git submodule status $i | cut -c1`
   if [ "$INITIALIZED" != "-" ]; then
      git config submodule.$i.url $ORIGIN/$i
   fi
done
git submodule update

if [ "$2" = "skipTests" ]; then
   mvn clean install -T1C -DskipTests
else
   mvn clean install
fi
