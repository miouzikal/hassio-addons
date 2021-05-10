#!/usr/bin/env bashio

ADDON_NAME=$(bashio::addon.name)

if [ ! -d "/addons/$ADDON_NAME/app" ] || [ -z "$(ls -A /addons/$ADDON_NAME/app)" ]; then
  bashio::log.info "Downloading binance-trade-bot ..."
  mkdir -p /addons/$ADDON_NAME/app
  git clone https://github.com/edeng23/binance-trade-bot.git /addons/$ADDON_NAME/app
else
  bashio::log.info "binance-trade-bot already present ... "
fi

bashio::log.info "Installing missing requirements (if any) ..."
pip install -r /addons/$ADDON_NAME/app/requirements.txt -q