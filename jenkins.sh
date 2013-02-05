#!/bin/bash -xe
export GOVUK_ASSET_ROOT=http://static.dev.gov.uk
export RAILS_ENV=test

git clean -fdx

bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment

bundle exec rake
