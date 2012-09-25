require 'mail'
require 'yaml'

class ExceptionMailer
  def self.deliver_exception_notification(message)
    mailer_file = YAML.load_file("config/mailer.yml")
    environment = ENV['GOVUK_ENV'] || "development"

    unless mailer_file["development_mode"]
      Mail.deliver do
        delivery_method :smtp, {
            :address => "smtp.gmail.com", :port => 587, :domain => 'alphagov.co.uk',
            :user_name => mailer_file[environment]["username"].to_s, :password => mailer_file[environment]["password"].to_s, :authentication => 'plain',
            :enable_starttls_auto => true
        }
        from 'Winston Smith-Churchill <winston@alphagov.co.uk>'
        to mailer_file[environment]["mailid"].to_s
        subject "Feedback: error creating ticket. Please refer to log."
        body message
      end
    end
  end
end