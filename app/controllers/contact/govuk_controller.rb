class Contact::GovukController < ContactController
  before_action proc {
    hide_report_a_problem_form_in_response
  },
                only: %i[anonymous_feedback_thankyou named_contact_thankyou]
  before_action :check_govuk_contact_form

  def anonymous_feedback_thankyou; end

  def named_contact_thankyou; end

private

  def check_govuk_contact_form
    @govuk_contact_form = params[:govuk_contact_form] == "true"
  end

  def ticket_class
    ContactTicket
  end

  def type
    :contact
  end
end
