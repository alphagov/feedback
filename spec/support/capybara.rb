require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist
Capybara.ignore_hidden_elements = false

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, { phantomjs_options: ['--ssl-protocol=TLSv1'] })
end

RSpec.configuration.include Capybara::DSL, type: :request
