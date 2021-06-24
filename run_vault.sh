#!/bin/bash
set -e

echo "Starting vault server ..."
exec vault server -dev

