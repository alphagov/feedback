source "https://rubygems.org"

gem "rails", "5.2.3"

if ENV["SLIMMER_DEV"]
  gem "slimmer", path: "../slimmer"
else
  gem "slimmer", "~> 13.2.2"
end

gem "govuk_publishing_components", "~> 21.38.2"

gem "plek", "~> 3.0.0"

gem "valid_email", "~> 0.1.3"

gem "invalid_utf8_rejector"
gem "rack_strip_client_ip", "0.0.2"

gem "asset_bom_removal-rails", "~> 1.0.2"
gem "sass", "~> 3.7.4"
gem "sass-rails", "~> 5.0.7"
gem "uglifier", "~> 4.2.0"

gem "google-api-client", "~> 0.37"

gem "notifications-ruby-client"

if ENV["API_DEV"]
  gem "gds-api-adapters", path: "../gds-api-adapters"
else
  gem "gds-api-adapters", "63.5.1"
end

gem "govuk_app_config", "~> 2.1.2"

group :development, :test do
  gem "ci_reporter_rspec"
  gem "govuk-content-schema-test-helpers"
  gem "govuk_test"
  gem "pry-byebug"
  gem "rails-controller-testing"
  gem "rspec-rails", "~> 4.0"
  gem "rubocop-govuk", "~> 3.3.1"
  gem "shoulda-matchers", "~> 4.3.0"
  gem "webmock", "~> 3.8.3", require: false
end
