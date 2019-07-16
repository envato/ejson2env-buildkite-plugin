#!/bin/bash -e

docker-compose run --rm tests
docker-compose run --rm lint
