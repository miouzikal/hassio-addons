#!/usr/bin/env bashio

ADDON_NAME=$(bashio::addon.name)
BOT_REPO=$(bashio::config 'BOT_REPO')
REPO_BRANCH=$(bashio::config 'REPO_BRANCH')

CONTAINER_ALREADY_STARTED=".CONTAINER_ALREADY_STARTED_PLACEHOLDER"
if [ ! -e /addons/$ADDON_NAME/$CONTAINER_ALREADY_STARTED ]; then
  mkdir -p /addons/$ADDON_NAME/
  echo $BOT_REPO'#'$REPO_BRANCH > /addons/$ADDON_NAME/$CONTAINER_ALREADY_STARTED
  bashio::log.info "First container startup ... Starting Initial Setup"

  /scripts/install_binance_trade_bot.sh
  /scripts/init.sh
  /scripts/override.sh

  bashio::log.info "Initial Setup complete ... Exiting"
else
  if [ -e /addons/$ADDON_NAME/_override_/devmode ]; then
    bashio::log.info "Running in Development mode ..."
    while true; do
      sleep 1m
    done
  else
    if [[ $BOT_REPO != $(cat /addons/$ADDON_NAME/$CONTAINER_ALREADY_STARTED | cut -d '#' -f 1) ]] || [[ $REPO_BRANCH != $(cat /addons/$ADDON_NAME/$CONTAINER_ALREADY_STARTED | cut -d '#' -f 2) ]]; then
      echo $BOT_REPO'#'$REPO_BRANCH > /addons/$ADDON_NAME/$CONTAINER_ALREADY_STARTED
      /scripts/update_binance_trade_bot.sh
    else
      /scripts/install_binance_trade_bot.sh
    fi
    /scripts/init.sh
    /scripts/override.sh
    cd /addons/$ADDON_NAME/btb_manager_telegram/
    bashio::log.info "Starting binance-trade-bot via btb_manager_telegram..."
    python3 -m btb_manager_telegram -p /addons/$ADDON_NAME/app/

  fi
fi