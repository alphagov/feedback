# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"
ENV["GOVUK_RATE_LIMIT_TOKEN"] = "bypass-please!"

require "simplecov"
SimpleCov.start "rails" do
  enable_coverage :branch
  minimum_coverage line: 95
end

require File.expand_path("../config/environment", __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "spec_helper"
require "rspec/rails"

Rack::Attack.enabled = false

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure(&:filter_rails_from_backtrace!)
RSpec.configure(&:infer_spec_type_from_file_location!)
