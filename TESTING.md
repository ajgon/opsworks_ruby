# Testing

## Unit Testing and Linting

```
docker-compose run -e SKIP="AuthorName AuthorEmail" cookbook \
bash -c "overcommit --sign && overcommit -r && rspec"
```

## Integration Testing

To run integration tests you need [Chef Development Kit](https://downloads.chef.io/chefdk).
After installing it, invoke:

```
chef exec bundle install -j 4 --path vendor
sudo chef exec bundle exec rake integration:docker
```
