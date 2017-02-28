require 'notifications/client'
require 'notifications/client/response_notification'

class SurveyNotifyService
  class Error < StandardError
    attr_reader :cause
    def initialize(message, cause = nil)
      super(message)
      @cause = cause
    end
  end

  def initialize(api_key)
    @api_key = api_key
  end

  def send_email(survey_signup)
    client.send_email(survey_signup.to_notify_params)
  rescue Notifications::Client::RequestError => e
    raise Error.new("Communication with notify service failed", e)
  end

private

  def client
    @client ||= Notifications::Client.new(@api_key)
  end
end
