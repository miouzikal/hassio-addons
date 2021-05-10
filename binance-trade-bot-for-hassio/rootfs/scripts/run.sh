#!/usr/bin/env bashio

ADDON_NAME=$(bashio::addon.name)

if [ -e /addons/$ADDON_NAME/_override_/testmode ]; then
  bashio::log.info "Running in dev mode ..."
  while true; do 
    sleep 1m
  done
else
  /scripts/install_binance_trade_bot.sh
  /scripts/init.sh
  /scripts/override.sh

  cd /addons/$ADDON_NAME/app/
  bashio::log.info "Starting binance-trade-bot ..."
  python3 -m binance_trade_bot
fi