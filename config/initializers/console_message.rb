Rails.application.console do
  puts("You are in the #{ENV['GOVUK_ENVIRONMENT']} environment") # rubocop:disable Rails/Output
  Rails.logger.info("Console started in the #{ENV['GOVUK_ENVIRONMENT']} environment")
end
