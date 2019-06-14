#!/bin/sh

# Color variables.
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# Starts or removes containers with macOS specific overrides.
docker() {
  if [ "$1" = "up" ]; then
    docker-compose -f docker-compose.yml -f docker-compose.mac.yml up -d
  elif [ "$1" = "down" ]; then
    docker-compose -f docker-compose.yml -f docker-compose.mac.yml down
  fi
}

# Runs Drush commands inside the container.
drush() {
  docker-compose exec --user www-data app /var/www/html/vendor/bin/drush --root="/var/www/html/web" $@
}

# Runs Drupal console commands inside the container.
drupal() {
  docker-compose exec --user www-data app /var/www/html/vendor/bin/drupal $@
}

# Runs Composer commands inside the container.
composer() {
  docker-compose exec --user www-data app composer "$@"
}

# Runs Behat inside the container.
behat() {
  docker-compose exec app vendor/bin/behat --config web/profiles/contrib/gu_profile/behat.yml $@
}

# Runs PHPUnit inside the container.
phpunit() {
  docker-compose exec --user www-data app vendor/bin/phpunit -c web/core $@
}

# Runs PHP_CodeSniffer inside the container.
phpcs() {
  docker-compose exec --user www-data app vendor/bin/phpcs --standard=vendor/drupal/coder/coder_sniffer/Drupal/ruleset.xml $@
}

# Runs PHP Code Beautifier and Fixer inside the container.
phpcbf() {
  docker-compose exec --user www-data app vendor/bin/phpcbf --standard=vendor/drupal/coder/coder_sniffer/Drupal/ruleset.xml $@
}

# Builds frontend.
devgulp() {
  echo "Building themes..."
  # TODO: Example provided. Modify to the project needs.
  # (cd src/web/themes/my_theme && yarn install && npx gulp build)
}

# Initializes the project.
# TODO: Remove this in your project after you've run it.
init_project() {

  # Make sure containers are started.
  docker-compose ps app | grep 'Up' &> /dev/null
  if [ $? != 0 ]; then
    echo "${RED}Error: Containers are not started. Please start them. Check README.md for instructions.${NC}"
    exit 1;
  fi

  echo "\n${GREEN}Initializing the project.${NC}"
  echo "${YELLOW}This might take several minutes...${NC}"

  # Remove template git folder and initialize a new repository.
  rm -rf .git \
    && git init

  # The src folder needs to exist for docker mounting, but it needs to be empty
  # for the composer create-project.
  rm src/.gitkeep

  # Set up src from drupal-composer/drupal-project.
  # Since we have a function called composer in this file, we need to find the
  # actual binary so that we don't try to route it into the container.
  COMPOSER=$(which composer)
  ${COMPOSER} create-project drupal-composer/drupal-project:8.x-dev src --no-interaction

  # Remove unused files.
  rm src/LICENSE
  rm src/README.md
  rm src/phpunit.xml.dist
  rm src/.travis.yml

  # Set up .env file.
  rm src/.env.example \
    && cp template-files/.env.example src/.env.example \
    && cp src/.env.example src/.env

  # Set up drush.yml file.
  rm src/drush/drush.yml \
    && cp template-files/drush.yml src/drush/drush.yml

  # Fix gitignore.
  sed -i '' '/\/web\/sites\/\*\/settings.php/d' src/.gitignore

  # Append database details to settings.php.
  echo "⚠️  ${YELLOW}You might need to supply sudo password in order to fix file permissions for settings.php${NC}"
  sudo chmod -R +w src/web/sites/default && \
    cat template-files/settings.php >> src/web/sites/default/settings.php

  # Install Drupal with standard profile and export the configuration.
  time drush site-install standard --yes \
    && drush cex --yes

  # Since standard can't be reinstalled due to implementing hook_install(), we
  # set it to minimal. It makes no difference in the end since we install from
  # existing config.
  sed -i '' "s/standard/minimal/g" src/config/sync/core.extension.yml

   # Remove template files.
  rm -rf template-files

  # Re-install Drupal to have correct active configuration.
  time docker-compose exec \
    --user www-data \
    app \
    /var/www/html/vendor/bin/drush site-install --existing-config \
    --root="/var/www/html/web" \
    --yes

  echo "${GREEN}Project initialization complete!${NC}"
  echo "${YELLOW}Please update dev.sh according to the TODOs defined.${NC}"
}

# Installs the site from config.
drupal_site_install() {
  # Fix permissions due to native NFS sync.
  docker-compose exec --user www-data app chmod -R 777 /var/www/html/web/sites/default/files

  # Install Drupal.
  time docker-compose exec \
    --user www-data \
    app \
    /var/www/html/vendor/bin/drush site-install --existing-config \
    --root="/var/www/html/web" \
    --yes

# TODO: Uncomment these sections if you have a multilingual site.
#  # Register translations.
#  echo "Importing translations..."
#  docker-compose exec \
#    --user www-data \
#    app \
#    /var/www/html/vendor/bin/drush locale-check \
#    --root="/var/www/html/web" \
#    --quiet \
#    --yes
#
#  # Import the translations.
#  docker-compose exec \
#    --user www-data \
#    app \
#    /var/www/html/vendor/bin/drush locale-update \
#    --root="/var/www/html/web" \
#    --quiet \
#    --yes

  echo "...done!"
}

"$@"
