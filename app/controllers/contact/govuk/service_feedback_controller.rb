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
    redirect_to action: :thankyou
  end

  def thankyou
  end

  def respond_to_invalid_submission(ticket)
    # for now, ignore just discard invalid submissions
    # because the actual form lives in the "frontend" app,
    # it's not straightforward to re-render the form with
    # the user's original input
    confirm_submission
  end
end
