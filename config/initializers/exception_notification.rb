# This file overwritten on deployment

Rails.application.config.middleware.use ExceptionNotification::Rack,
  email: {
    :email_prefix => "[Feedback (development)] ",
    :sender_address => %{"Winston Smith-Churchill" <winston@alphagov.co.uk>},
    :exception_recipients => %w{govuk-exceptions@digital.cabinet-office.gov.uk}
  }
