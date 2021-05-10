#!/usr/bin/env bashio

ADDON_NAME=$(bashio::addon.name)

if [ -e /addons/$ADDON_NAME/_override_/ ]; then
  bashio::log.info 'Installing "_override_" files ...'
  if [ -L /addons/$ADDON_NAME/app/data/ ] ; then unlink /addons/$ADDON_NAME/app/data/; fi
  if [ -e /addons/$ADDON_NAME/app/data/ ] ; then rm -rf /addons/$ADDON_NAME/app/data/; fi
  ln -s /addons/$ADDON_NAME/_override_/data/ /addons/$ADDON_NAME/app/
  find /addons/$ADDON_NAME/_override_/ -type f -not -path "*/data/*" | sed -e "s/_override_/app/" | xargs -I {} bash -c 'if [ -L {} ] ; then unlink {} ; fi'
  find /addons/$ADDON_NAME/_override_/ -type f -not -path "*/data/*" | sed -e "s/_override_/app/" | xargs -I {} bash -c 'if [ -e {} ] ; then rm {} ; fi'
  find /addons/$ADDON_NAME/_override_/ -type f -not -path "*/data/*" | sed -e "p;s/_override_/app/" | xargs -n2 ln -s 2> /dev/null
else
  bashio::log.info '"_override_" not found ... Installing defaults ...'
  mkdir -p /addons/$ADDON_NAME/_override_
  cp -r /_defaults_/* /addons/$ADDON_NAME/_override_
  mkdir -p /addons/$ADDON_NAME/_override_/data/
  rm -r /addons/$ADDON_NAME/app/data/
  ln -s /addons/$ADDON_NAME/_override_/data/ /addons/$ADDON_NAME/app/
  find /addons/$ADDON_NAME/_override_/ -type f -not -path "*/data/*" | sed -e "s/_override_/app/" | xargs -I {} bash -c 'if [ -e {} ] ; then rm {} ; fi'
  find /addons/$ADDON_NAME/_override_/ -type f -not -path "*/data/*" | sed -e "p;s/_override_/app/" | xargs -n2 ln -s 2> /dev/null
fi