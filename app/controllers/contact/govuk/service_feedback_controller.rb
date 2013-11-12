require 'utf8_cleaner'

class Contact::Govuk::ServiceFeedbackController < ContactController
  private
  def ticket_class
    ServiceFeedback
  end

  def type
    :service_feedback
  end

  def confirm_submission
    respond_to do |format|
      format.html do
        render "thankyou"
      end
    end
  end

  def respond_to_invalid_submission(ticket)
    # for now, ignore just discard invalid submissions
    # because the actual form lives in the "frontend" app,
    # it's not straightforward to re-render the form with
    # the user's original input
    confirm_submission
  end
end
