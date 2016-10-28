module Contact
  module Govuk
    class AssistedDigitalHelpWithFeesFeedbackController < ContactController
    private
      def ticket_class
        AssistedDigitalHelpWithFeesFeedback
      end

      def type
        :assisted_digital_help_with_fees_feedback
      end

      def contact_params
        params[:service_feedback] || {}
      end

      def confirm_submission
        redirect_to contact_anonymous_feedback_thankyou_path
      end

      def respond_to_invalid_submission(_ticket)
        # for now, ignore just discard invalid submissions
        # because the actual form lives in the "frontend" app,
        # it's not straightforward to re-render the form with
        # the user's original input
        confirm_submission
      end
    end
  end
end
