source 'https://rubygems.org'

gem 'rails', '5.2.1'

if ENV['SLIMMER_DEV']
  gem 'slimmer', path: '../slimmer'
else
  gem 'slimmer', '~> 13.0.0'
end

gem 'govuk_publishing_components', '~> 12.12.1'

gem 'plek', '~> 2.1.1'

gem 'valid_email', '~> 0.1.2'

gem 'rack_strip_client_ip', '0.0.2'
gem 'invalid_utf8_rejector'

gem 'uglifier', '~> 4.1.19'
gem 'govuk_frontend_toolkit', '8.1.0'
gem 'sass', '~> 3.7.2'
gem 'sass-rails', '~> 5.0.7'
gem 'asset_bom_removal-rails', '~> 1.0.2'

gem 'google-api-client', '~> 0.25'

gem 'notifications-ruby-client'

if ENV['API_DEV']
  gem 'gds-api-adapters', path: '../gds-api-adapters'
else
  gem 'gds-api-adapters', '54.1.2'
end

gem 'govuk_app_config', '~> 1.10.0'

group :development, :test do
  gem 'govuk-content-schema-test-helpers'
  gem 'govuk_test'
  gem 'govuk-lint'
  gem 'rspec-rails', '~> 3.8'
  gem 'rails-controller-testing'
  gem 'webmock', '~> 3.4.2', require: false
  gem 'shoulda-matchers', '~> 3.0.1'
  gem 'test-unit', '3.2.8'
  gem 'pry-byebug'
  gem 'ci_reporter_rspec'
end
