source 'https://rubygems.org'
source 'https://gems.gemfury.com/vo6ZrmjBQu5szyywDszE/'

gem 'rails', '3.2.8'

if ENV['SLIMMER_DEV']
  gem "slimmer", :path => '../slimmer'
else
  gem "slimmer", '2.0.0'
end

gem "unicorn", '4.3.1'
gem "router-client", '3.1.0', :require => false

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  #gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  gem 'rspec-rails', '2.11.0'
  gem 'capybara', '1.1.2'
  gem 'simplecov', '0.6.4'
  gem 'simplecov-rcov', '0.2.3'
end
