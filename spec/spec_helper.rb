ENV["GOVUK_WEBSITE_ROOT"] ||= "https://www.dev.gov.uk"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.before(:each, type: :system) do
    driven_by :rack_test
    Rails.application.config.emergency_banner_redis_client = instance_double(Redis, hgetall: {})
  end
end
