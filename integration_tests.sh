#!/bin/sh -e

printUsage() {
   echo "Usage : "
   echo "./integration_tests.sh URL BRANCH JAMES_IP JAMES_IMAP_PORT"
   echo "    URL : URL of the repository to pull"
   echo "    BRANCH : Branch to build"
   echo "    JAMES_IP : IP of the James server to be tests"
   echo "    JAMES_IMAP_PORT : Exposed IMAP port of this James server"
   exit 1
}

if [ "$#" -ne 4 ]; then
    printUsage
fi

URL=$1
BRANCH=$2

export JAMES_ADDRESS=$3
export JAMES_IMAP_PORT=$4

git clone $URL -b $BRANCH
cd james-parent
git submodule init
git submodule update

mvn -Dtest=ExternalJamesTest -DfailIfNoTests=false -pl org.apache.james:apache-james-mpt-external-james -am test
