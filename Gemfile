source 'https://rubygems.org'

gem 'rails', '~> 5.0.1'

if ENV['SLIMMER_DEV']
  gem 'slimmer', path: '../slimmer'
else
  gem 'slimmer', '~> 10.1.1'
end

gem 'unicorn', '~> 4.9.0'

gem 'plek', '~> 1.11.0'
gem 'airbrake', github: 'alphagov/airbrake', branch: 'silence-dep-warnings-for-rails-5'

gem 'valid_email', '~> 0.0.11'

gem 'statsd-ruby', '~> 1.2.1', require: 'statsd'
gem 'logstasher', '0.6.2'

gem 'uglifier', '~> 2.7.2'
gem 'govuk_frontend_toolkit', '1.6.0'
gem 'sass', '~> 3.4.18'
gem 'sass-rails', '~> 5.0.4'

gem 'google-api-client', '~> 0.9'

gem 'notifications-ruby-client'

if ENV['API_DEV']
  gem 'gds-api-adapters', path: '../gds-api-adapters'
else
  gem 'gds-api-adapters', '~> 43.0.0'
end

group :development, :test do
  gem 'govuk-content-schema-test-helpers'
  gem 'govuk-lint'
  gem 'rspec-rails', '~> 3.5.2'
  gem 'rspec-activemodel-mocks'
  gem 'capybara', '~> 2.7.0'
  gem 'webmock', '~> 3.0.0'
  gem 'poltergeist', '~> 1.6.0'
  gem 'shoulda-matchers', '~> 2.8.0'
  gem 'test-unit', '3.1.3'
  gem 'rails-controller-testing'
  gem 'pry-byebug'
  gem 'ci_reporter_rspec'
end
