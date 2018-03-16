## Development server

docker-compose up

## Deploy

```
docker-compose run --rm -e JEKYLL_ENV=production cookbook bash -c "git config --global user.email \"$(git config --global user.email)\" && git config --global user.name \"$(git config --global user.name)\" && rake site:publish"
```
