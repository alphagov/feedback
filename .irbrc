def application_name
  Rails.application.class.module_parent.name
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

if defined?(Rails)
  prompt = "#{application_name} (#{colorised_govuk_environment}})"

  # defining custom prompt
  IRB.conf[:PROMPT][:RAILS] = {
    PROMPT_I: "#{prompt}>> ",
    PROMPT_N: "#{prompt}> ",
    PROMPT_S: "#{prompt}* ",
    PROMPT_C: "#{prompt}? ",
    RETURN: " => %s\n",
  }

  # Setting our custom prompt as prompt mode
  IRB.conf[:PROMPT_MODE] = :RAILS
end
