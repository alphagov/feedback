source 'https://rubygems.org'

gem 'rails', '5.1.4'

if ENV['SLIMMER_DEV']
  gem 'slimmer', path: '../slimmer'
else
  gem 'slimmer', '~> 11.1.0'
end

gem 'plek', '~> 2.0.0'

gem 'valid_email', '~> 0.1.0'

gem 'rack_strip_client_ip', '0.0.2'
gem 'invalid_utf8_rejector'

gem 'uglifier', '~> 4.1.4'
gem 'govuk_frontend_toolkit', '7.2.0'
gem 'sass', '~> 3.5.5'
gem 'sass-rails', '~> 5.0.7'
gem 'asset_bom_removal-rails', '~> 1.0.2'

gem 'google-api-client', '~> 0.19'

gem 'notifications-ruby-client'

if ENV['API_DEV']
  gem 'gds-api-adapters', path: '../gds-api-adapters'
else
  gem 'gds-api-adapters', '51.1.0'
end

gem 'govuk_app_config', '~> 1.2.1'

group :development, :test do
  gem 'govuk-content-schema-test-helpers'
  gem 'govuk-lint'
  gem 'rspec-rails', '~> 3.7'
  gem 'rails-controller-testing'
  gem 'capybara', '~> 2.17'
  gem 'webmock', '~> 3.3.0', require: false
  gem 'poltergeist'
  gem 'shoulda-matchers', '~> 3.0.1'
  gem 'test-unit', '3.2.7'
  gem 'pry-byebug'
  gem 'ci_reporter_rspec'
end
