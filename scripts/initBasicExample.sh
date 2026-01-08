#!/usr/bin/env bash

SCRIPT=`pwd`/$0
FILENAME=`basename $SCRIPT`
PATHNAME=`dirname $SCRIPT`
ROOT=$PATHNAME/..
BUILD_DIR=$ROOT/build
CURRENT_DIR=`pwd`
NVM_CHECK="$PATHNAME"/checkNvm.sh
EXTRAS=$ROOT/extras

cp $ROOT/nuve/nuveClient/dist/nuve.js $EXTRAS/basic_example/

. $NVM_CHECK

nvm use
cd $EXTRAS/basic_example
# Start Basic Example Server with PM2
echo $ROOT/node_modules/.bin/pm2 start basicServer.js --cwd .
$ROOT/node_modules/.bin/pm2 start basicServer.js --cwd .
#node basicServer.js &
