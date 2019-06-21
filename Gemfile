source 'https://rubygems.org'

gem 'rails', '5.2.3'

if ENV['SLIMMER_DEV']
  gem 'slimmer', path: '../slimmer'
else
  gem 'slimmer', '~> 13.1.0'
end

gem 'govuk_publishing_components', '~> 17.4.0'

gem 'plek', '~> 3.0.0'

gem 'valid_email', '~> 0.1.3'

gem 'invalid_utf8_rejector'
gem 'rack_strip_client_ip', '0.0.2'

gem 'asset_bom_removal-rails', '~> 1.0.2'
gem 'govuk_frontend_toolkit', '8.2.0'
gem 'sass', '~> 3.7.4'
gem 'sass-rails', '~> 5.0.7'
gem 'uglifier', '~> 4.1.20'

gem 'google-api-client', '~> 0.30'

gem 'notifications-ruby-client'

if ENV['API_DEV']
  gem 'gds-api-adapters', path: '../gds-api-adapters'
else
  gem 'gds-api-adapters', '59.5.1'
end

gem 'govuk_app_config', '~> 1.19.0'

group :development, :test do
  gem 'ci_reporter_rspec'
  gem 'govuk-content-schema-test-helpers'
  gem 'govuk-lint'
  gem 'govuk_test'
  gem 'pry-byebug'
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 3.8'
  gem 'shoulda-matchers', '~> 3.0.1'
  gem 'webmock', '~> 3.6.0', require: false
end
