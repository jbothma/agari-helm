#!/bin/bash
# Simple wrapper for helm commands with environment-specific values
#
# Usage:
#   utils/helm-env install agari score dev
#   utils/helm-env upgrade agari score dev
#   utils/helm-env uninstall agari score dev
#   utils/helm-env diff agari score dev

set -e

COMMAND=$1
NAMESPACE=$2
APP_NAME=$3
ENV=$4

if [ -z "$COMMAND" ] || [ -z "$NAMESPACE" ] || [ -z "$APP_NAME" ] || [ -z "$ENV" ]; then
  echo "Usage: $0 <install|upgrade|uninstall|diff> <namespace> <app_name> <environment>"
  exit 1
fi
CHART_PATH="./helm/${APP_NAME}"
VALUES_FILE="./helm/values/${ENV}/${APP_NAME}.yaml"

# Build values file argument if it exists
VALUES_ARG=""
if [ -f "$VALUES_FILE" ]; then
  echo "Using values file: $VALUES_FILE"
  VALUES_ARG="-f $VALUES_FILE"
else
  echo "No $ENV env file found."
fi

case "$COMMAND" in
  install|upgrade)
    helm "$COMMAND" "$APP_NAME" "$CHART_PATH" -n "$NAMESPACE" $VALUES_ARG
    ;;
  uninstall)
    helm uninstall "$APP_NAME" -n "$NAMESPACE"
    ;;
  diff)
    helm diff upgrade "$APP_NAME" "$CHART_PATH" -n "$NAMESPACE" $VALUES_ARG
    ;;
  *)
    echo "Error: Unknown command: $COMMAND"
    echo "Supported commands: install, upgrade, uninstall, diff"
    exit 1
    ;;
esac
