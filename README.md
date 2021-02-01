# README

It is a bot for receiving project updates compatible with your skills.
You can run bot with command `bin/rake telegram:bot:poller`

## Ruby version

2.6.3

## System dependencies

postgres (PostgreSQL) 12.3

## Configuration

Create `.env` file with variables:
* **FREELANCEHUNT_TOKEN**      - generate token here [APPS and API](https://freelancehunt.com/my/api)
* **TELEGRAM_BOT_TOKEN**       - get from @botfather
* **TELEGRAM_SECRET_KEY_BASE** - get from @botfather

## Database creation

```
rails db:create
rails db:migrate
```

## How to run the test suite

run `rspec` in repo

## Services

Bot uses Redis for external requests caching.

## Deployment instructions

* Create account on heroku
* Install heroku CLI on you local machine
* Create app
* Install add-ons:
  * _heroku-postgresql
  * _heroku-redis
  * _Heroku Scheduler_ and create job `bundle exec rake send_projects_updates`
* Add GitHub repo to heroku app
* Create dyno with code inside: `bot bundle exec rake telegram:bot:poller PORT=$PORT` and toggle it to on
* Deploy fron CLI or from [Heroku dashboard](https://dashboard.heroku.com)


