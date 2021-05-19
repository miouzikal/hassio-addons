import random
import sys
import time
import os
import json
from datetime import datetime, timezone

from binance_trade_bot.auto_trader import AutoTrader
from binance_trade_bot.models import Trade

class Strategy(AutoTrader):
    def initialize(self):
        super().initialize()
        self.initialize_current_coin()
        self.scount_loop_count = 0
        self.ha_update_loop_count = 0

    def scout(self):
        """
        Scout for potential jumps from the current coin to another coin
        """
        current_coin = self.db.get_current_coin()
        
        current_coin_price = self.manager.get_ticker_price(current_coin + self.config.BRIDGE)
        self.log_scout(current_coin, current_coin_price)

        if current_coin_price is None:
            self.logger.info("Skipping scouting... current coin {} not found".format(current_coin + self.config.BRIDGE))
            return

        self._jump_to_best_coin(current_coin, current_coin_price)

        # Update HA sensor AFTER doing the bot functions so that any breakage in HA won't affect trading.
        # E.g. HA API changes, etc.
        self.update_ha_sensor(current_coin, current_coin_price)

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
                self.manager.buy_alt(current_coin, self.config.BRIDGE)
                self.logger.info("Ready to start trading")

    def log_scout(self, current_coin, current_coin_price, wait_iterations=60, notification=False):
      """
      Log each scout every X times. This will prevent logs getting spammed.
      """

      if self.scount_loop_count == wait_iterations:
        # Log the current coin+Bridge, so users can see *some* activity and not think the bot has
        # stopped. Don't send to notification service
        self.logger.info(f"Scouting... current: {current_coin + self.config.BRIDGE} (price: {current_coin_price})", notification=notification)
        self.scount_loop_count = 0

      self.scount_loop_count += 1

    def update_ha_sensor(self, current_coin, current_coin_price, wait_iterations=30):
      """
      Update the Home Assistant sensor with new data every 30 seconds.
      """
      if self.ha_update_loop_count == wait_iterations:
        self.ha_update_loop_count = 0
        total_balance_usdt = 0
        total_coin_in_btc = 0
        attributes = {}
        attributes['bridge'] = self.config.BRIDGE_SYMBOL
        attributes['current_coin'] = str(current_coin).replace("<", "").replace(">", "")
        attributes['wallet'] = {}

        for asset in self.manager.binance_client.get_account()["balances"]:
          if float(asset['free']) > 0:
            if asset['asset'] not in ['BUSD', 'USDT']:
              current_price = self.manager.get_ticker_price(asset['asset'] + self.config.BRIDGE_SYMBOL)
              if isinstance(current_price, float):
                asset_value = float(asset['free']) * float(current_price)
              else:
                self.logger.warning("No price found for current asset={}".format(asset['asset']))
                asset_value = 0
            else:
              asset_value = float(asset['free'])

            total_balance_usdt += asset_value

            if asset_value > 1:

              # Get total amount in terms of BTC amount
              current_coin_btc_asset_value = 0
              try:
                current_coin_price_in_btc = self.manager.get_ticker_price(current_coin + "BTC")
                current_coin_btc_asset_value = float(current_coin_price_in_btc) * float(asset['free'])
                total_coin_in_btc += current_coin_btc_asset_value
              except:
                # Pretty unlikely since all coins trade with BTC
                self.logger.warning("No price found for current coin + BTC={}".format(current_coin + "BTC"), notification=False)
                pass
                
              attributes['wallet'][asset['asset']] = {
                'balance': float(asset['free']), 
                'current_price': float(current_price), 
                'asset_value_us_dollar': round(asset_value, 2),
                'asset_value_in_btc': round(current_coin_btc_asset_value, 4)
              }

        with self.db.db_session() as session:
          try:
            trade = session.query(Trade).order_by(Trade.datetime.desc()).limit(1).one().info()
            if trade:
                attributes['last_transaction_attempt'] = datetime.strptime(trade['datetime'], "%Y-%m-%dT%H:%M:%S.%f").replace(tzinfo=timezone.utc).astimezone(tz=None).strftime("%d/%m/%Y %H:%M:%S")
          except: 
            pass
        
        attributes['last_sensor_update'] = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
        attributes['sensor_update_interval'] = wait_iterations

        data = {
          'state': round(total_coin_in_btc, 4),
          'unit_of_measurement': 'BTC',
          'attributes': attributes
        }
        os.system("/scripts/update_ha_sensor.sh '" + str(json.dumps(data)) + "'")

      self.ha_update_loop_count += 1
