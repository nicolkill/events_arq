
up:
	docker compose up

up_build:
	docker compose up --build

backend-test:
	docker compose run --rm -e "MIX_ENV=test" backend mix test

backend-iex:
	docker compose exec backend iex -S mix

backend-bash:
	docker compose exec backend sh

backend-routes:
	docker compose exec backend mix phx.routes

backend-rollback:
	docker compose exec backend mix ecto.rollback

backend-migrate:
	docker compose exec backend mix ecto.migrate

backend-format:
	docker compose exec backend mix format
