#!/usr/bin/env bash

set -e

SCRIPT=`pwd`/$0
FILENAME=`basename $SCRIPT`
PATHNAME=`dirname $SCRIPT`
ROOT=$PATHNAME/..
NVM_CHECK="$ROOT"/scripts/checkNvm.sh
CURRENT_DIR=`pwd`

. $NVM_CHECK

cd $PATHNAME/nuveAPI

# Start Nuve with PM2
echo $ROOT/node_modules/.bin/pm2 start nuve.js --cwd .
$ROOT/node_modules/.bin/pm2 start nuve.js --cwd .
#node nuve.js &

cd $CURRENT_DIR
