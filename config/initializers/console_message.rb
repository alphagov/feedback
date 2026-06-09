Rails.application.console do
  puts("You are in the GOV.UK #{colorised_govuk_environment} environment")
  puts("Be very cautious in the production environment!") if govuk_environment == "production"
  Rails.logger.info("Console started in the #{ENV['GOVUK_ENVIRONMENT']} environment")
end

def govuk_environment
  ENV["GOVUK_ENVIRONMENT"]
end

def colorised_govuk_environment
  case govuk_environment
  when "integration", "staging"
    IRB::Color.colorize(ENV["GOVUK_ENVIRONMENT"], [:YELLOW])
  when "production"
    IRB::Color.colorize(ENV["GOVUK_ENVIRONMENT"], [:RED])
  else
    IRB::Color.colorize(ENV["GOVUK_ENVIRONMENT"], [:BLUE])
  end
end
