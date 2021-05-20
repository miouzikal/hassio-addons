# Changelog

## 0.1.7

- Fix logging
- Add hassio_idkravitz_btc_default_strategy

## 0.1.6

- Use idkravitz requirements when building image

## 0.1.5

- Add support for configuring BUY/SELL types

## 0.1.4

- Add support for other repos and branches
- Revert to eventlet==0.30.2
- Update Dockerfile requirement to match latest bot requirements
- Add initial bot upgrade logic
- Add hassio default strategy for idkravitz branch

## 0.1.3

- Add bot requirements directly in Dockerfile
- Remove requirements.txt
- Patch hassio_default strategy to account for missing coin price (thanks @finbarr)
- Fix hassio_default strategy to account for missing 'last_transaction' if no transaction made
- Change Development mode trigger from 'testmode' to 'devmode'
- Add 'Initial Setup' logic
- Update requirement - eventlet==0.31.0

## 0.1.2

- Fix Changelog formatting

## 0.1.1

- Change hassio sensor default attributes

## 0.1.0

- Initial Release
