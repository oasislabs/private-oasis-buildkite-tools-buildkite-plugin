#!/bin/bash

##
# Checks if ci deploys for staging/production are enabled
#
# Usage:
#
#     ci_deploys_enabled.sh <env>
#
# Where:
#   <env>          - environment to check: either 'staging' or 'production'
#
# This script relies on read-only google scripts that returns weather deploys are currently enabled.
#
#
# Example:
#
#     ./ci_deploys_enabled.sh staging
#
##

set -euox pipefail

usage() {
    echo "Usage: $0 <env>" >&2
    echo >&2
    exit 1
}

ENV=$1

# Public, read-only script checks if deployment is enabled:
#  https://script.google.com/a/oasislabs.com/d/1J-Wht_FDyo0n7zDAsWczMFC5_jM2Fs020fe6upGpioMpMkpRFf1TyQRk/edit
PAUSED_SCRIPT="https://script.google.com/macros/s/AKfycbzt2wHEoGQ5nI0FMQV_NnaWJdnfHBTlTa47ZdmJOditY7KSn-hO/exec?env=$ENV"

IS_DEPLOYED_PAUSED=$(curl -L "${PAUSED_SCRIPT}")

if  "$IS_DEPLOYED_PAUSED" != "false" ; then
    echo "Deploys for '$ENV' disabled, ask '#ops' team for the reason."
    exit 1
fi
