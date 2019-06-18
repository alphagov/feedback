module Contact
  module Govuk
    class EmailSurveySignupController < ContactController
      rescue_from SurveyNotifyService::Error, with: :respond_to_notify_error

      DONE_INVALID_EMAIL = "<h2>Sorry, we’re unable to send your message as you haven’t given us a valid email address.</h2> " +
        "<p>Enter an email address in the correct format, like name@example.com</p>"

      SERVICE_UNAVAILABLE = "<h2>Sorry, we’re unable to receive your message right now.<h2> " +
        "<p>If the problem persists, we have other ways for you to provide feedback on the contact page.</p>"
      def create
        data = contact_params.merge(browser_attributes)
        ticket = EmailSurveySignup.new(data)

        if ticket.valid?
          GovukStatsd.increment("email_survey_signup.successful_submission")
          @contact_provided = (not data[:email].blank?)

          respond_to_valid_submission(ticket)
        else
          GovukStatsd.increment("email_survey_signup.invalid_submission")
          raise SpamError if ticket.spam?

          @errors = ticket.errors.to_hash
          @old = data

          respond_to_invalid_submission(ticket)
        end
      end

      def contact_params
        params[:email_survey_signup] || {}
      end

      def confirm_submission
        if ajax_request?
          render json: { message: "email survey sign up success" }, status: :ok
        else
          redirect_to contact_anonymous_feedback_thankyou_path
        end
      end

      def respond_to_invalid_submission(ticket)
        @message = DONE_INVALID_EMAIL.html_safe
        if ajax_request?
          render json: { message: @message, errors: ticket.errors }, status: :unprocessable_entity
        else
          # for now, ignore just discard invalid submissions
          # because the actual form lives in the "frontend" app,
          # it's not straightforward to re-render the form with
          # the user's original input
          confirm_submission
        end
      end

      def respond_to_notify_error(exception)
        @message = SERVICE_UNAVAILABLE.html_safe
        if ajax_request?
          log_exception(exception)
          render json: { message: @message, errors: exception.cause.message }, status: :service_unavailable
        else
          unable_to_create_ticket_error(exception)
        end
      end

    private

      def ajax_request?
        request.xhr? || request.format == :js
      end
    end
  end
end
