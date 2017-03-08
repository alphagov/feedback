module Contact
  module Govuk
    class EmailSurveySignupController < ContactController
      rescue_from SurveyNotifyService::Error, with: :respond_to_notify_error

      def ticket_class
        EmailSurveySignup
      end

      def type
        :email_survey_signup
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
        if ajax_request?
          render json: { message: "email survey sign up failure", errors: ticket.errors }, status: :unprocessable_entity
        else
          # for now, ignore just discard invalid submissions
          # because the actual form lives in the "frontend" app,
          # it's not straightforward to re-render the form with
          # the user's original input
          confirm_submission
        end
      end

      def respond_to_notify_error(exception)
        if ajax_request?
          log_exception(exception)
          render json: { message: "email survey sign up failure", errors: exception.cause.message }, status: :service_unavailable
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
