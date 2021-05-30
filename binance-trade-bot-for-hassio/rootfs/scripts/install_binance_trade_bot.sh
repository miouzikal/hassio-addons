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

bashio::log.info "Installing missing bot requirements (if any) ..."
pip install -r /addons/$ADDON_NAME/app/requirements.txt -q

BPB_MANAGER_PATH=/addons/$ADDON_NAME/btb_manager_telegram

if [ ! -d "$BPB_MANAGER_PATH" ] || [ -z "$(ls -A $BPB_MANAGER_PATH)" ]; then
  bashio::log.info "Cloning btb_manager_telegram ..."
  mkdir -p $BPB_MANAGER_PATH
  git clone https://github.com/lorcalhost/BTB-manager-telegram.git $BPB_MANAGER_PATH
else
  bashio::log.info "btb_manager_telegram already present in $BPB_MANAGER_PATH..."
fi

bashio::log.info "Installing missing btb_manager_telegram requirements (if any) ..."
pip install -r $BPB_MANAGER_PATH/requirements.txt -q