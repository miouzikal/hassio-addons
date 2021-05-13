#!/usr/bin/env bashio

ADDON_NAME=$(bashio::addon.name)
BOT_REPO=$(bashio::config 'BOT_REPO')

bashio::log.info 'Removing symlinks ...'
if [ -L /addons/$ADDON_NAME/app/data/ ] ; then unlink /addons/$ADDON_NAME/app/data/; fi
find /addons/$ADDON_NAME/_override_/ -type f -not -path "*/data/*" | sed -e "s/_override_/app/" | xargs -I {} bash -c 'if [ -L {} ] ; then unlink {} ; fi'

bashio::log.info 'Updating binance-trade-bot from "'$BOT_REPO'"'
mkdir -p /addons/$ADDON_NAME/app
git clone $BOT_REPO /addons/$ADDON_NAME/app

bashio::log.info "Installing missing requirements (if any) ..."
pip install -r /addons/$ADDON_NAME/app/requirements.txt -q