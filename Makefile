
up:
	docker compose up

up_build:
	docker compose up --build

testing:
	docker compose run --rm -e "MIX_ENV=test" app mix test

iex:
	docker compose exec app iex -S mix

bash:
	docker compose exec app sh

routes:
	docker compose exec app mix phx.routes

rollback:
	docker compose exec app mix ecto.rollback

migrate:
	docker compose exec app mix ecto.migrate

format:
	docker compose exec app mix format
