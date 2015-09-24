source 'https://rubygems.org'

gem 'rails', '4.2.4'

if ENV['SLIMMER_DEV']
  gem 'slimmer', path: '../slimmer'
else
  gem 'slimmer', '8.2.1'
end

gem 'unicorn', '4.9.0'

gem 'plek', '1.11.0'
gem 'airbrake', '3.1.15'

gem 'valid_email', '0.0.11'

gem 'statsd-ruby', '1.2.1', require: 'statsd'
gem 'logstasher', '0.4.8'
gem 'rack_strip_client_ip', '0.0.1'
gem 'invalid_utf8_rejector'

gem 'uglifier', '2.1.2'
gem 'govuk_frontend_toolkit', '1.6.0'
gem 'sass', '3.3.9'
gem 'sass-rails', '5.0.4'

if ENV['API_DEV']
  gem 'gds-api-adapters', path: '../gds-api-adapters'
else
  gem 'gds-api-adapters', '23.2.2'
end

group :development, :test do
  gem 'govuk-lint'
  gem 'rspec-rails', '3.3.3'
  gem 'capybara', '2.5.0'
  gem 'simplecov', '0.6.4', require: false
  gem 'simplecov-rcov', '0.2.3', require: false
  gem 'webmock', '1.21.0', require: false
  gem 'poltergeist', '1.6.0'
  gem 'shoulda-matchers', '2.8.0'
  gem 'test-unit', '3.1.3'
end
