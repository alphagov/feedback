#!/bin/bash -xe
export GOVUK_ASSET_ROOT=http://static.dev.gov.uk
export RAILS_ENV=test

git clean -fdx

bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment

if [[ ${GIT_BRANCH} != "origin/master" ]]; then
  bundle exec govuk-lint-ruby \
    --rails \
    --format html --out rubocop-${GIT_COMMIT}.html \
    --format clang \
  app lib spec
fi

bundle exec rake
bundle exec rake assets:precompile
