Rails.application.console do
  puts("You are in the #{ENV['GOVUK_ENVIRONMENT']} environment") # rubocop:disable Rails/Output
  Rails.logger.info("Console started in the #{ENV['GOVUK_ENVIRONMENT']} environment")
end

module Rails
  class Console
    class IRBConsole
      def colorized_env
        case ENV["GOVUK_ENVIRONMENT"]
        when "integration", "staging"
          IRB::Color.colorize(ENV["GOVUK_ENVIRONMENT"], [:YELLOW])
        when "production"
          IRB::Color.colorize(ENV["GOVUK_ENVIRONMENT"], [:RED])
        else
          IRB::Color.colorize(ENV["GOVUK_ENVIRONMENT"], [:BLUE])
        end
      end
    end
  end
end
