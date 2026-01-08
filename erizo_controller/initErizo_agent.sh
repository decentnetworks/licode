#!/usr/bin/env bash
set -e

SCRIPT=`pwd`/$0
FILENAME=`basename $SCRIPT`
ROOT=`dirname $SCRIPT`
LICODE_ROOT="$ROOT"/..
CURRENT_DIR=`pwd`
NVM_CHECK="$LICODE_ROOT"/scripts/checkNvm.sh

export LD_LIBRARY_PATH="$LICODE_ROOT/build/libdeps/build/lib"

. $NVM_CHECK

cd $ROOT/erizoAgent
nvm use
# Start Erizo Agent with PM2
echo $LICODE_ROOT/node_modules/.bin/pm2 start nuve.js --cwd .
$LICODE_ROOT/node_modules/.bin/pm2 start erizoAgent.js --cwd .
#node erizoAgent.js $* &

cd $CURRENT_DIR
