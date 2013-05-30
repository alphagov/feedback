require 'zendesk_api/error'
require 'zendesk_didnt_create_ticket_error'
require 'spam_error'

class ApplicationController < ActionController::Base
  rescue_from SpamError, with: :error_444
  rescue_from ZendeskDidntCreateTicketError, ZendeskAPI::Error::ClientError, with: :zendesk_error

protected
  def error_444; render nothing: true, status: 444; end

  def zendesk_error(exception)
    if exception and Rails.application.config.middleware.detect{ |x| x.klass == ExceptionNotifier }
      if exception.respond_to?(:errors)
        message = { data: { message: "Zendesk errors: #{exception.errors}" } }
        ExceptionNotifier::Notifier.exception_notification(request.env, exception, message).deliver
      else
        ExceptionNotifier::Notifier.exception_notification(request.env, exception).deliver
      end
    end

    respond_to do |format|
      format.html do
        render text: "", status: 503
      end
      format.js do
        response = "<p>Sorry, we're unable to receive your message right now.</p> " +
                   "<p>We have other ways for you to provide feedback on the " +
                   "<a href='/feedback'>support page</a>.</p>"
        render json: { status: "error", message: response }, status: 503
      end
    end
  end
end
