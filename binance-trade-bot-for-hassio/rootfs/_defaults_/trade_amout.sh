#!/bin/bash
while read -r i; do
sqlite3 data/crypto_trading.db <<EOF
SELECT "alt_coin_id", "alt_trade_amount" ,"datetime" FROM (SELECT * FROM 'trade_history' WHERE alt_coin_id="$i") WHERE selling = FALSE ORDER BY datetime DESC
EOF
done < ../app/supported_coin_list
