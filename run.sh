#!/bin/bash

function printtime {
  START=$(date +%s)
  "$@"
  END=$(date +%s)
  DIFF=$(echo "$END - $START" | bc)
  echo -e "\033[97;48;5;21m ${DIFF} seconds\x1B[K\033[0m\n"
}

function colorecho {
  echo  -e "\033[30;48;5;82m $1 \x1B[K\033[0m"
}


function runTest {
  pushd "$1" || exit

  colorecho "### $1: removing old containers"
  printtime docker-compose down -v >/dev/null || true
  chmod -R +w ./ || true
  rm -rf drupal

  colorecho "### $1: cloning base repo"
  printtime git clone https://github.com/amazeeio/drupal-example.git drupal

  colorecho "### $1: starting container"
  printtime docker-compose up -d --force >/dev/null

  colorecho "### $1: composer install"
  printtime docker-compose exec cli bash -c 'composer install --no-dev --no-interaction'

  colorecho "### $1: drush site install 3x"
  for i in `seq 1 3`;
  do
      printtime docker-compose exec cli bash -c 'cd web && drush -y si config_installer --account-name=blub --account-mail=bla@bla.com'
  done

  colorecho "### $1: drush cr 3x"
  for i in `seq 1 3`;
  do
      printtime docker-compose exec cli bash -c 'cd web && drush -y cr'
  done

  colorecho "### $1: removing container and data"
  printtime docker-compose down -v >/dev/null || true
  chmod -R +w ./ || true
  rm -rf drupal

  popd || exit
}

# colorecho "### CACHALOT"
# # Loading env variables so that we use Cachalot (Docker Machine)
# cachalot up >/dev/null
# eval $(amazeeio-cachalot env)

# runTest cachalot

# # Removing Cachalot Docker Environment Variables again, now we use Docker for Mac
# # see https://docs.docker.com/docker-for-mac/docker-toolbox/
cachalot halt >/dev/null
unset ${!DOCKER_*}

colorecho "### Docker for Mac - delegated"
runTest delegated

colorecho "### Docker for Mac - cached"
runTest cached

colorecho "### Docker for Mac - consistent"
runTest consistent
