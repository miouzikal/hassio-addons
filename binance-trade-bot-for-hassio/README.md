# Binance Trade Bot for Hassio

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

![Current version][version]

## About

Home Assistant Add-on to run an instance of [binance-trade-bot](https://github.com/edeng23/binance-trade-bot)
The "hassio_default_strategy.py" lets the bot create a sensor in hassio with some information regarding the binance assets

## New Installation

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store** and add this URL as an additional repository: `https://github.com/miouzikal/hassio-addons`
2. Find the "Binance Trade Bot for Hassio" add-on and click the "INSTALL" button.
3. Configure the add-on and click on "START".

## Installation with existing Database

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store** and add this URL as an additional repository: `https://github.com/miouzikal/hassio-addons`
2. Find the "Binance Trade Bot for Hassio" add-on and click the "INSTALL" button.
3. Start the add-on with the default configuration and let it run for a few seconds
   - The add-on will log errors since there is no valid API keys.
5. Stop the add-on.
7. Copy your existing database in `/addons/_override_/data/` (overwrite any files in the destination folder)
8. Configure the add-on
9. Start the add-on

## Overriding files

You can override any file of the bot by putting an edited version of the file in the _override_ folder, respecting the bot's folder structure.
  i.e. to override "/app/binance_trade_bot/binance_api_manager.py", create a file in "/_override_/binance_trade_bot/binance_api_manager.py", make the necessary changes to that file and restart the add-on
  
## For information regarding the setup and configuration of the bot, reffer to the bot's [git page](https://github.com/edeng23/binance-trade-bot)
## This Add-on is provided as-is and I am not responsible for any problems you may end up with in your Hassio or Binance setup.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[version]: https://img.shields.io/badge/version-v0.1.2-blue.svg
