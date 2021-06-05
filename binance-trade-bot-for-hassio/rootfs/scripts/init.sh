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
EOF

if [[ $(bashio::config 'BUY_ORDER_TYPE') != null ]]; then
  echo buy_order_type = $(bashio::config 'BUY_ORDER_TYPE') >> /addons/$ADDON_NAME/app/user.cfg
fi

if [[ $(bashio::config 'SELL_ORDER_TYPE') != null ]]; then
  echo sell_order_type = $(bashio::config 'SELL_ORDER_TYPE') >> /addons/$ADDON_NAME/app/user.cfg
fi

if [[ $(bashio::config 'BUY_MAX_PRICE_CHANGE') != null ]]; then
  echo buy_max_price_change = $(bashio::config 'BUY_MAX_PRICE_CHANGE') >> /addons/$ADDON_NAME/app/user.cfg
fi

if [[ $(bashio::config 'SELL_MAX_PRICE_CHANGE') != null ]]; then
  echo sell_max_price_change = $(bashio::config 'SELL_MAX_PRICE_CHANGE') >> /addons/$ADDON_NAME/app/user.cfg
fi

if [[ $(bashio::config 'PRICE_TYPE') != null ]]; then
  echo price_type = $(bashio::config 'PRICE_TYPE') >> /addons/$ADDON_NAME/app/user.cfg
fi

if [[ $(bashio::config 'MAX_IDLE_HOURS') != null ]]; then
  echo max_idle_hours = $(bashio::config 'MAX_IDLE_HOURS') >> /addons/$ADDON_NAME/app/user.cfg
fi

bashio::log.info "Updating 'supported_coin_list' ..."
cat > /addons/$ADDON_NAME/app/supported_coin_list << EOF
$(bashio::config 'SUPPORTED_COIN_LIST')
EOF
