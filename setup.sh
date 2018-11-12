#!/bin/bash

function setupCache {
  chmod -R +w composer-cache drupal
  rm -rf composer-cache drupal
  mkdir -p composer-cache drupal

  mkdir -p composer-cache
  COMPOSER_CACHE_DIR=$PWD/composer-cache composer install --no-interaction --no-dev
}

# Remove existing dir
rm -rf base

echo "### downloading base repo"
git clone https://github.com/amazeeio/drupal-example.git base || true
cd base || exit
git pull || true

echo "### warming composer-cache to be mounted into docker containers"
setupCache