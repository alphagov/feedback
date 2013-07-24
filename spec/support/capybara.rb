require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist
Capybara.ignore_hidden_elements = false

RSpec.configuration.include Capybara::DSL, :type => :request