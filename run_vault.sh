#!/bin/bash
set -e

echo "Starting vault server ..."
exec vault server -config vault_config.hcl -log-level=trace

