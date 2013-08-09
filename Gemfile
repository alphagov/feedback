source 'https://rubygems.org'
source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

gem 'rails', '3.2.14'

if ENV['SLIMMER_DEV']
  gem "slimmer", :path => '../slimmer'
else
  gem "slimmer", '3.17.0'
end

gem "unicorn", '4.3.1'
gem "router-client", '3.1.0', :require => false

gem "exception_notification", '4.0.0'
gem "aws-ses", :require => 'aws/ses'
gem "plek", "1.4.0"

gem "zendesk_api", "0.4.0.rc1"
gem "valid_email", "0.0.4"

gem "statsd-ruby", "1.2.1", require: "statsd"
gem "rest-client", "1.6.7"

if ENV['API_DEV']
  gem "gds-api-adapters", :path => '../gds-api-adapters'
else
  gem "gds-api-adapters", "7.3.0"
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '2.1.2'
  gem 'govuk_frontend_toolkit', '0.32.2'
  gem 'sass', '3.2.1'
  gem 'sass-rails', "  ~> 3.2.3"
end

group :development, :test do
  gem 'rspec-rails', '2.14.0'
  gem 'capybara', '2.1.0'
  gem 'simplecov', '0.6.4'
  gem 'simplecov-rcov', '0.2.3'
  gem 'webmock', '1.13.0', :require => false
  gem 'poltergeist', '1.3.0'
end
