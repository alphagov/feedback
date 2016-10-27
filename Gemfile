source 'https://rubygems.org'

gem 'rails', '~> 4.0'

if ENV['SLIMMER_DEV']
  gem 'slimmer', path: '../slimmer'
else
  gem 'slimmer', '~> 9.0.1'
end

gem 'unicorn', '~> 4.9.0'

gem 'plek', '~> 1.11.0'
gem 'airbrake', '~> 4.3.1'

gem 'valid_email', '~> 0.0.11'

gem 'statsd-ruby', '~> 1.2.1', require: 'statsd'
gem 'logstasher', '0.6.2'
gem 'rack_strip_client_ip', '0.0.1'
gem 'invalid_utf8_rejector'

gem 'uglifier', '~> 2.7.2'
gem 'govuk_frontend_toolkit', '1.6.0'
gem 'sass', '~> 3.4.18'
gem 'sass-rails', '~> 5.0.4'

if ENV['API_DEV']
  gem 'gds-api-adapters', path: '../gds-api-adapters'
else
  gem 'gds-api-adapters', '36.3.0'
end

group :development, :test do
  gem 'govuk-lint'
  gem 'rspec-rails', '~> 3.4.0'
  gem 'capybara', '~> 2.5.0'
  gem 'webmock', '~> 1.21.0', require: false
  gem 'poltergeist', '~> 1.6.0'
  gem 'shoulda-matchers', '~> 2.8.0'
  gem 'test-unit', '3.1.3'
end
