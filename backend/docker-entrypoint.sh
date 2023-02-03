#!/bin/sh

set -e

if [ "$1" = 'start' ]; then
	mix deps.get
	mix ecto.create
	mix ecto.migrate

  mix phx.server
fi

exec "$@"
