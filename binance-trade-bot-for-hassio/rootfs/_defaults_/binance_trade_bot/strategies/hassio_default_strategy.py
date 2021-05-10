import random
import sys
import time
import os
import json
from datetime import datetime, timezone

from binance_trade_bot.auto_trader import AutoTrader
from binance_trade_bot.models import Trade

# from sqlalchemy.orm import Session

class Strategy(AutoTrader):
    def initialize(self):
        super().initialize()
        self.initialize_current_coin()

    def scout(self):
        """
        Scout for potential jumps from the current coin to another coin
        """
        all_tickers = self.manager.get_all_market_tickers()

        current_coin = self.db.get_current_coin()

        current_coin_price = all_tickers.get_price(current_coin + self.config.BRIDGE)

        if current_coin_price is None:
            self.logger.info("Skipping scouting... current coin {} not found".format(current_coin + self.config.BRIDGE))
            return

        # Update Home Assistant sensor
        total_balance_usdt = 0
        attributes = {}
        attributes['bridge'] = self.config.BRIDGE_SYMBOL
        attributes['current_coin'] = str(current_coin).replace("<", "").replace(">", "")
        attributes['wallet'] = {}

        ratio_dict = self._get_ratios(current_coin, current_coin_price, all_tickers)
        if ratio_dict:
            next_best_pair = max(ratio_dict, key=ratio_dict.get)

        for asset in self.manager.binance_client.get_account()["balances"]:
          if float(asset['free']) > 0:
            if asset['asset'] not in ['BUSD', 'USDT']:
              current_price = all_tickers.get_price(asset['asset'] + self.config.BRIDGE_SYMBOL)
              asset_value = float(asset['free']) * float(current_price)
            else:
              asset_value = float(asset['free'])

            total_balance_usdt += asset_value

            if asset_value > 1:
              attributes['wallet'][asset['asset']] = {'balance': float(asset['free']), 'current_price': float(current_price), 'asset_value': float(asset_value)}

        with self.db.db_session() as session:
          trade = session.query(Trade).order_by(Trade.datetime.desc()).limit(1).one().info()
          if trade:
            transaction = {}
            if trade['selling']:
              transaction['transaction'] = 'SELL'
            else:
              transaction['transaction'] = 'BUY'

            transaction['coin'] = trade['alt_coin']['symbol']
            transaction['amount'] = trade['alt_trade_amount']
            transaction['state'] = trade['state']
            transaction['datetime'] = datetime.strptime(trade['datetime'], "%Y-%m-%dT%H:%M:%S.%f").replace(tzinfo=timezone.utc).astimezone(tz=None).strftime("%d/%m/%Y %H:%M:%S")
    
        attributes['last_transaction'] = transaction
        attributes['last_update'] = datetime.now().strftime("%d/%m/%Y %H:%M:%S")

        # Update HA Sensor
        data = {'state': round(total_balance_usdt, 2), 'attributes': attributes}
        os.system("/scripts/update_ha_sensor.sh '" + str(json.dumps(data)) + "'")

        self._jump_to_best_coin(current_coin, current_coin_price, all_tickers)
        self.bridge_scout()

    def bridge_scout(self):
        current_coin = self.db.get_current_coin()
        if self.manager.get_currency_balance(current_coin.symbol) > self.manager.get_min_notional(
            current_coin.symbol, self.config.BRIDGE.symbol
        ):
            # Only scout if we don't have enough of the current coin
            return
        new_coin = super().bridge_scout()
        if new_coin is not None:
            self.db.set_current_coin(new_coin)

    def initialize_current_coin(self):
        """
        Decide what is the current coin, and set it up in the DB.
        """
        if self.db.get_current_coin() is None:
            current_coin_symbol = self.config.CURRENT_COIN_SYMBOL
            if not current_coin_symbol:
                current_coin_symbol = random.choice(self.config.SUPPORTED_COIN_LIST)

            self.logger.info(f"Setting initial coin to {current_coin_symbol}")

            if current_coin_symbol not in self.config.SUPPORTED_COIN_LIST:
                sys.exit("***\nERROR!\nSince there is no backup file, a proper coin name must be provided at init\n***")
            self.db.set_current_coin(current_coin_symbol)

            # if we don't have a configuration, we selected a coin at random... Buy it so we can start trading.
            if self.config.CURRENT_COIN_SYMBOL == "":
                current_coin = self.db.get_current_coin()
                self.logger.info(f"Purchasing {current_coin} to begin trading")
                all_tickers = self.manager.get_all_market_tickers()
                self.manager.buy_alt(current_coin, self.config.BRIDGE, all_tickers)
                self.logger.info("Ready to start trading")

