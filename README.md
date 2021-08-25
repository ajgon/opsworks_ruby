## Development server

docker-compose up

## Lint schema.json

```
docker-compose run --rm cookbook_web ruby /app/data/lint.rb
```

## Deploy

```
docker-compose run --rm -e JEKYLL_ENV=production cookbook_web bash -c "git config --global user.email \"$(git config --global user.email)\" && git config --global user.name \"$(git config --global user.name)\" && bundle exec rake site:publish"
```
