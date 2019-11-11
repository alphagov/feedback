#!/bin/bash -xe
export GOVUK_ASSET_ROOT=http://static.dev.gov.uk
export RAILS_ENV=test

git clean -fdx

bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment

if [[ ${GIT_BRANCH} != "origin/master" ]]; then
  bundle exec rubocop \
    --rails \
    --format html --out rubocop-${GIT_COMMIT}.html \
    --format clang \
  app lib spec
fi

# Clone govuk-content-schemas depedency for tests
rm -rf tmp/govuk-content-schemas
git clone git@github.com:alphagov/govuk-content-schemas.git tmp/govuk-content-schemas
export GOVUK_CONTENT_SCHEMAS_PATH=tmp/govuk-content-schemas

bundle exec rake
bundle exec rake assets:precompile
