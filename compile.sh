#!/bin/sh -e
#

printUsage() {
   echo "Usage : "
   echo "./compile.sh [-s | --skipTests] [-u URL | --url URL] BRANCH"
   echo "    -s : Skip test"
   echo "    -u URL : clone the given URL for retrieving sources"
   echo "    BRANCH : Branch to build"
   exit 1
}

MODE=local
ORIGIN=/origin
DESTINATION=/destination

for arg in "$@"
do
   case $arg in
      -s|--skipTests)
         SKIPTESTS="skipTests"
         ;;
      -u|--url)
         echo "$1 $2"
         MODE="distant"
         REPO_URL=$2
         shift
         ;;
      -*)
         echo "Invalid option: -$OPTARG"
         printUsage
         ;;
      *)
         if ! [ -z "$1" ]; then
            echo "BRANCH $1"
            BRANCH=$1
         fi
         ;;
   esac
   if [ "0" -lt "$#" ]; then
      echo "Shifting"
      shift
   fi
done

if [ -z "$BRANCH" ]; then
   echo "You must provide a BRANCH name"
   printUsage
fi

# Sources retrieval

if [ $MODE = "local" ]; then
   git clone $ORIGIN/. -b $BRANCH
   for i in `git submodule | cut -d' ' -f2`; do
      INITIALIZED=`cd $ORIGIN; git submodule status $i | cut -c1`
      if [ "$INITIALIZED" != "-" ]; then
         git config submodule.$i.url $ORIGIN/$i
      fi
   done
else
   git clone $REPO_URL -b $BRANCH
   cd james-parent
fi
git submodule init
git submodule update

# Compilation

if [ "$SKIPTESTS" = "skipTests" ]; then
   mvn clean install -T1C -DskipTests -Pcassandra,with-assembly
else
   mvn clean install -Pcassandra,with-assembly 
fi

# Retrieve result

if [ $? -eq 0 ]; then
   cp modules/james/app/target/james-server-app-*-app.zip $DESTINATION
fi
