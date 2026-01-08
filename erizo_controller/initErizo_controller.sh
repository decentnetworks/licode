#!/usr/bin/env bash

set -e

SCRIPT=`pwd`/$0
FILENAME=`basename $SCRIPT`
ROOT=`dirname $SCRIPT`
LICODE_ROOT="$ROOT"/..
CURRENT_DIR=`pwd`
NVM_CHECK="$LICODE_ROOT"/scripts/checkNvm.sh

. $NVM_CHECK

cd $ROOT/erizoController
nvm use
# Start Erizo Controller with PM2
echo $ROOT/node_modules/.bin/pm2 start nuve.js --cwd .
$ROOT/node_modules/.bin/pm2 start erizoController.js --cwd .
#node erizoController.js &

cd $CURRENT_DIR
