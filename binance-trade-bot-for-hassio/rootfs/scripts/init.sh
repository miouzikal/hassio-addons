#!/usr/bin/env bashio

ADDON_NAME=$(bashio::addon.name)

bashio::log.info "Creating 'user.cfg' ..."
cat > /addons/$ADDON_NAME/app/user.cfg << EOF
[binance_user_config]
api_key = $(bashio::config 'API_KEY')
api_secret_key = $(bashio::config 'API_SECRET_KEY')
current_coin = $(bashio::config 'CURRENT_COIN_SYMBOL')
bridge = $(bashio::config 'BRIDGE_SYMBOL')
tld = $(bashio::config 'TLD')
hourToKeepScoutHistory = $(bashio::config 'HOUR_TO_KEEP_SCOUT_HISTORY')
scout_multiplier = $(bashio::config 'SCOUT_MULTIPLIER')
scout_sleep_time = $(bashio::config 'SCOUT_SLEEP_TIME')
strategy = $(bashio::config 'STRATEGY')
buy_timeout = $(bashio::config 'BUY_TIMEOUT')
sell_timeout = $(bashio::config 'SELL_TIMEOUT')
buy_order_type = $(bashio::config 'BUY_ORDER_TYPE')
sell_order_type = $(bashio::config 'SELL_ORDER_TYPE')
EOF

bashio::log.info "Updating 'supported_coin_list' ..."
cat > /addons/$ADDON_NAME/app/supported_coin_list << EOF
$(bashio::config 'SUPPORTED_COIN_LIST')
EOF
