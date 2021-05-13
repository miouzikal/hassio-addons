#!/usr/bin/env bashio

ADDON_NAME=$(bashio::addon.name)
BOT_REPO=$(bashio::config 'BOT_REPO')
REPO_BRANCH=$(bashio::config 'REPO_BRANCH')

if [ ! -d "/addons/$ADDON_NAME/app" ] || [ -z "$(ls -A /addons/$ADDON_NAME/app)" ]; then
  bashio::log.info "Downloading binance-trade-bot ..."
  mkdir -p /addons/$ADDON_NAME/app
  git clone -b $REPO_BRANCH $BOT_REPO /addons/$ADDON_NAME/app
else
  bashio::log.info "binance-trade-bot already present ..."
fi

bashio::log.info "Installing missing requirements (if any) ..."
pip install -r /addons/$ADDON_NAME/app/requirements.txt -q