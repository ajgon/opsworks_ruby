# Testing

## Unit Testing and Linting

```
docker-compose run --rm -e SKIP="AuthorName AuthorEmail" cookbook \
bash -c "overcommit --sign && overcommit -r && rspec"
```

## Integration Testing

To run integration tests you need [Chef Development Kit](https://downloads.chef.io/chefdk)
and [Vagrant](https://www.vagrantup.com/).
After installing it, invoke:

```
kitchen converge
kitchen verify
```
