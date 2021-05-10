#!/usr/bin/env bashio

declare ADDON_NAME=$(bashio::addon.name)
declare SENSOR_NAME="sensor.${ADDON_NAME//-/_}"
declare SENSOR_URL="/core/api/states/${SENSOR_NAME}"
declare DATA=${1}

if ! response=$(curl --silent --show-error \
    --write-out '\n%{http_code}' --request "POST" \
    -H "Authorization: Bearer ${__BASHIO_SUPERVISOR_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "${DATA}" \
    "${__BASHIO_SUPERVISOR_API}${SENSOR_URL}"
); then
    bashio::log.debug "${response}"
    bashio::log.error "Something went wrong contacting the API"
    exit 2
fi

status=${response##*$'\n'}
response=${response%$status}

bashio::log.debug "API Status: ${status}"
bashio::log.debug "API Response: ${response}"

if [[ "${status}" -eq 200 || "${status}" -eq 201 ]]; then
    bashio::log.debug "${status} ${response}"
else
    bashio::log.error "${status} ${response}"
    exit ${status}
fi