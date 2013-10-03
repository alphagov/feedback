require 'spam_error'
require 'gds_api/exceptions'

class ApplicationController < ActionController::Base
  rescue_from SpamError, with: :robot_script_submission_detected
  rescue_from GdsApi::BaseError, with: :unable_to_create_ticket_error

protected
  def robot_script_submission_detected
    headers[Slimmer::Headers::SKIP_HEADER] = "1"
    render nothing: true, status: 400
  end

  def unable_to_create_ticket_error(exception)
    ExceptionNotifier.notify_exception(exception, env: request.env)

    exception_class_name = exception.class.name.demodulize.downcase
    Statsd.new(::STATSD_HOST).increment("#{::STATSD_PREFIX}.exception.#{exception_class_name}")

    respond_to do |format|
      format.html do
        # no content needed here, will display the default 503 page
        headers[Slimmer::Headers::SKIP_HEADER] = "1"
        render nothing: true, status: 503
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
