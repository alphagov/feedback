require 'spam_error'
require 'gds_api/exceptions'

class ApplicationController < ActionController::Base
  rescue_from SpamError, with: :robot_script_submission_detected
  rescue_from GdsApi::BaseError, with: :unable_to_create_ticket_error

  include Slimmer::Template
  include Slimmer::GovukComponents
  slimmer_template 'wrapper'

protected

  def robot_script_submission_detected
    headers[Slimmer::Headers::SKIP_HEADER] = "1"
    head(:bad_request)
  end

  def unable_to_create_ticket_error(exception)
    log_exception(exception)

    respond_to do |format|
      format.html do
        # no content needed here, will display the default 503 page
        headers[Slimmer::Headers::SKIP_HEADER] = "1"
        head :service_unavailable
      end
      format.any(:js, :json) do
        response = "<p>Sorry, we're unable to receive your message right now.</p> " +
          "<p>We have other ways for you to provide feedback on the " +
          "<a href='/contact'>contact page</a>.</p>"
        render json: { status: "error", message: response }, status: 503
      end
    end
  end

  def hide_report_a_problem_form_in_response
    response.headers[Slimmer::Headers::REPORT_A_PROBLEM_FORM] = "false"
  end

  def log_exception(exception)
    notify_airbrake(exception)

    exception_class_name = exception.class.name.demodulize.downcase
    Statsd.new(::STATSD_HOST).increment("#{::STATSD_PREFIX}.exception.#{exception_class_name}")
  end
end
