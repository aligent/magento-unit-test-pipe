#!/usr/bin/env sh

set -e

REPOSITORY_URL=${REPOSITORY_URL:="https://repo.magento.com/"}
MAGENTO_VERSION=${MAGENTO_VERSION:="magento/project-community-edition:>=2.4.5 <2.4.6"}
BITBUCKET_CLONE_DIR=${BITBUCKET_CLONE_DIR:="/build"}

GROUP=${GROUP:=""}
TESTS_PATH=${TESTS_PATH:=""}

composer_setup () {
  if [ ! -f "composer.lock" ]; then
      echo "composer.lock does not exist."
      composer create-project --repository-url="$REPOSITORY_URL" "$MAGENTO_VERSION" /magento2 --no-install
      cd /magento2
      composer config repositories.local path $BITBUCKET_CLONE_DIR
      composer require $COMPOSER_PACKAGES "@dev" --no-update
  fi

  composer config --no-interaction allow-plugins.dealerdirect/phpcodesniffer-composer-installer true
  composer config --no-interaction allow-plugins.laminas/laminas-dependency-plugin true
  composer config --no-interaction allow-plugins.magento/* true
}

run_unit_tests () {
  composer_setup
  cat composer.json
  composer install

  vendor/bin/phpunit -c dev/tests/unit/phpunit.xml.dist $GROUP $TESTS_PATH
}

if [ ! -z "${COMPOSER_AUTH}" ]; then
  echo "Configuring composer credentials"
  echo $COMPOSER_AUTH > ~/.composer/auth.json
else
  echo "No composer credentials found. \n \n"
fi

run_unit_tests
