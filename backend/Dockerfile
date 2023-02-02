FROM hexpm/elixir:1.13.4-erlang-25.0-rc3-alpine-3.15.3

RUN apk update \
    && apk add --no-cache \
    git \
    curl \
    inotify-tools \
    build-base \
    make \
    linux-headers

# Install hex and rebar
RUN mix local.rebar --force && \
    mix local.hex --force

ENV APP_HOME /app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
COPY . .

ADD docker-entrypoint.sh .
ENTRYPOINT ["./docker-entrypoint.sh"]

CMD ["start"]
