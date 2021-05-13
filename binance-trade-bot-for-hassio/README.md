# Binance Trade Bot for Hassio

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

![Current version][version]

## Disclaimer
### This Add-on is provided as-is and I am not responsible for any problems you may end up with in your Hassio or Binance setup.
#### For information regarding the setup and configuration of the bot, refer to the bot's [git page](https://github.com/edeng23/binance-trade-bot)

## About

Home Assistant Add-on to run an instance of [binance-trade-bot](https://github.com/edeng23/binance-trade-bot)  
The "hassio_default_strategy.py" lets the bot create a sensor in hassio with some information regarding the binance assets

## New Installation

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store** and add this URL as an additional repository: `https://github.com/miouzikal/hassio-addons`
2. Find the "**Binance Trade Bot for Hassio**" add-on and click the "**INSTALL**" button
3. "**START**" the Add-on
   * The first boot will run the Initial Setup
4. Wait for the "**Initial Setup**" to complete
5. **Configure** the Add-on and click on "**START**"

## Installation with existing Database

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store** and add this URL as an additional repository: `https://github.com/miouzikal/hassio-addons`
2. Find the "**Binance Trade Bot for Hassio**" add-on and click the "**INSTALL**" button
3. "**START**" the Add-on
   * The first boot will run the Initial Setup
4. Wait for the "**Initial Setup**" to complete
5. **Copy your existing database** in `/addons/_override_/data/`
6. **Configure** the Add-on and click on "**START**"

## Overriding files

You can override any file of the bot by putting an edited version of the file in the `_override_` folder, respecting the bot's folder structure.  
> **NOTE:**  
> Your overriden files may not work as expected if you decide to change the repository and/or branch.  
> Make sure you update the override files as necessary.

**example :**  
To override `/app/binance_trade_bot/binance_api_manager.py`
  1. create a file in `/_override_/binance_trade_bot/binance_api_manager.py`
  2. make the necessary changes to that file
  3. restart the add-on  

## Changing Repo & Branch

Changing the default repository and branch through "BOT_REPO" & "REPO_BRANCH" config entries can break the Add-on.  
I tested it with "edeng23:master" and "idkravitz:websockets-pr" <u>only</u> so I don't know how the add-on will behave if you use another repo and/or branch.  
Make sure you understand the implications of the changes you make and always **save your DB and config** before doing anything.  
To keep the hassio sensor feature, you need to use the appropriate hassio_default strategy depending on the repository.

**i.e.**  
- idkravitz:websockets-pr -> hassio_idkravitz_default
- edeng23:master -> hassio_default
- any_other -> NOT TESTED


  
[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[version]: https://img.shields.io/badge/version-v0.1.4-blue.svg
