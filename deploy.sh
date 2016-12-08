#!/bin/bash

WSK='wsk' # Set if not in your $PATH
CURRENT_NAMESPACE=`$WSK property get --namespace | sed -n -e 's/^whisk namespace//p' | tr -d '\t '`
echo "Current namespace is $CURRENT_NAMESPACE."

function install() {
  $WSK action create handler handler.js
  $WSK action invoke --blocking handler

  $WSK trigger create every-20-seconds \
    --feed  /whisk.system/alarms/alarm \
    --param cron '*/20 * * * * *' \
    --param maxTriggers 6

  $WSK rule create \
    invoke-periodically \
    every-20-seconds \
    handler

  $WSK activation poll
}

function uninstall() {
  $WSK rule disable invoke-periodically
  $WSK rule delete invoke-periodically
  $WSK trigger delete every-20-seconds
  $WSK action delete handler
}


case "$1" in
"--install" )
install
;;
"--uninstall" )
uninstall
;;
* )
usage
;;
esac
