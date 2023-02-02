#!/bin/sh

set -e

if [ "$1" = 'start' ]; then
	npm install
	npm start
fi

exec "$@"
