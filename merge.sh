#!/bin/sh -e

printUsage() {
   echo "Usage : "
   echo "./merge.sh BRANCH RESULTING_BRANCH"
   echo "    BRANCH : Branch to merge with trunk"
   echo "    RESULTING_BRANCH : Resulting branch of the merge"
   exit 1
}

if [ "$#" -ne 2 ]; then
    printUsage
fi

BRANCH=$1
RESULTING_BRANCH=$2

git checkout $BRANCH
git submodule deinit *
rm -rf .git/modules/*
git submodule init
git submodule update
git submodule foreach git checkout trunk
git submodule foreach git checkout -b $RESULTING_BRANCH
git submodule foreach git merge origin/$BRANCH
git checkout trunk
git checkout -b $RESULTING_BRANCH
git merge origin/$BRANCH
git add modules/*
git commit --allow-empty -m "Select merge commits in submodules"
