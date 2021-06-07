#!/bin/bash
set -e

sqlite3 ../crypto_trading.db "select id,alt_trade_amount, datetime, alt_coin_id from trade_history where selling=0 and state='COMPLETE' and alt_coin_id=(select alt_coin_id from trade_history order by id DESC limit 1);" > results
starting_value=$(sed -n '1p' results| awk -F\| '{print $2}')

current_coin=$(sed -n '1p' results| awk -F\| '{print $4}')
echo "----"
echo "### Current Coin Progress ( $current_coin )"
echo

# echo "Trade No|Hodlings|Date|Current Coin|Grow %"

# echo "---|---|---|---"
# echo
while read p; do
   echo  "**Trade no:** "
   echo $p | awk -F\| '{print $1}'
   echo "**Grow:** "
   value=$(echo $p | awk -F\| '{print $2}')
   grow=$(awk "BEGIN {print ($value/$starting_value*100)-100}")
   echo $grow
   echo "%"
   echo  "**$current_coin Hodlings:** "
   echo $p | awk -F\| '{print $2}'
   echo "**Date:** "
   echo $p | awk -F\| '{print $3}'
   echo
   # echo "$p|$grow"
done <results

