source 'https://rubygems.org'

gem 'rails', '5.1.4'

if ENV['SLIMMER_DEV']
  gem 'slimmer', path: '../slimmer'
else
  gem 'slimmer', '~> 11.1.0'
end

gem 'unicorn', '~> 4.9.0'

gem 'plek', '~> 1.11.0'

gem 'valid_email', '~> 0.0.11'

gem 'logstasher', '0.6.2'
gem 'rack_strip_client_ip', '0.0.2'
gem 'invalid_utf8_rejector'

gem 'uglifier', '~> 3.2.0'
gem 'govuk_frontend_toolkit', '1.6.0'
gem 'sass', '~> 3.4.18'
gem 'sass-rails', '~> 5.0.4'
gem 'asset_bom_removal-rails', '~> 1.0.0'

gem 'google-api-client', '~> 0.10'

gem 'notifications-ruby-client'

if ENV['API_DEV']
  gem 'gds-api-adapters', path: '../gds-api-adapters'
else
  gem 'gds-api-adapters', '49.6.0'
end

gem 'govuk_app_config', '~> 0.3.0'

group :development, :test do
  gem 'govuk-content-schema-test-helpers'
  gem 'govuk-lint'
  gem 'rspec-rails', '~> 3.6'
  gem 'rails-controller-testing'
  gem 'capybara', '~> 2.5'
  gem 'webmock', '~> 3.1.0', require: false
  gem 'poltergeist'
  gem 'shoulda-matchers', '~> 2.8.0'
  gem 'test-unit', '3.1.3'
  gem 'pry-byebug'
  gem 'ci_reporter_rspec'
end
