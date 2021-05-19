import json
import os
import random
import sys
import time
from datetime import datetime, timezone

from binance_trade_bot.models import Trade
from binance_trade_bot.strategies.default_strategy import Strategy


class Strategy(Strategy):
    def initialize(self):
        super().initialize()
        self.scount_loop_count = 0
        self.ha_update_loop_count = 0

    def scout(self):
        """
        Scout for potential jumps from the current coin to another coin
        """
        block_print()
        super().scout()
        enable_print()
        current_coin = self.db.get_current_coin()
        self.log_scout(current_coin)

        # Update HA sensor AFTER doing the bot functions so that any breakage in HA won't affect trading.
        # E.g. HA API changes, etc.
        self.update_ha_sensor(current_coin)

    def bridge_scout(self):
        super().bridge_scout()

    def log_scout(self, current_coin, wait_iterations=300, notification=False):
        """
        Log each scout every X times. This will prevent logs getting spammed.
        """

        if self.scount_loop_count in [0, wait_iterations]:
            # Log the current coin+Bridge, so users can see *some* activity and not think the bot has
            # stopped. Don't send to notification service
            self.logger.info(f"Scouting... current: {current_coin + self.config.BRIDGE}", notification=notification)
            self.scount_loop_count = 0

        self.scount_loop_count += 1

    def update_ha_sensor(self, current_coin, wait_iterations=30):
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

                        if asset['asset'] not in ['BUSD', 'USDT']:
                            # Only check value if not in bridge coin.
                            try:
                                current_coin_price_in_btc = self.manager.get_ticker_price(current_coin + "BTC")
                                current_coin_btc_asset_value = float(current_coin_price_in_btc) * float(asset['free'])
                            except:
                                # Pretty unlikely since all coins trade with BTC
                                self.logger.warning(
                                    "No price found for current coin + BTC={}".format(current_coin + "BTC"),
                                    notification=False)
                                pass
                        elif asset['asset'] == 'USDT':
                            btc_to_usdt_price = self.manager.get_ticker_price("BTCUSDT")
                            current_coin_btc_asset_value = float(asset['free']) / float(btc_to_usdt_price)

                        total_coin_in_btc += current_coin_btc_asset_value

                        attributes['wallet'][asset['asset']] = {
                            'balance': float(asset['free']),
                            'current_price': float(current_price),
                            'asset_value_us_dollar': round(asset_value, 2),
                            'asset_value_in_btc': round(current_coin_btc_asset_value, 6)
                        }

            with self.db.db_session() as session:
                try:
                    trade = session.query(Trade).order_by(Trade.datetime.desc()).limit(1).one().info()
                    if trade:
                        attributes['last_transaction_attempt'] = datetime.strptime(trade['datetime'],
                                                                                   "%Y-%m-%dT%H:%M:%S.%f").replace(
                            tzinfo=timezone.utc).astimezone(tz=None).strftime("%d/%m/%Y %H:%M:%S")
                except:
                    pass

            attributes['last_sensor_update'] = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
            attributes['sensor_update_interval'] = wait_iterations
            attributes['unit_of_measurement'] = 'BTC'
            data = {
                'state': round(total_coin_in_btc, 6),
                'attributes': attributes
            }
            os.system("/scripts/update_ha_sensor.sh '" + str(json.dumps(data)) + "'")

        self.ha_update_loop_count += 1


def block_print():
    """
    Block print command working.
    """
    sys.stdout = open(os.devnull, 'w')


def enable_print():
    """
    Restore print command working.
    """
    sys.stdout = sys.__stdout__
