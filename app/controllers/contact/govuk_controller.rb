require 'slimmer/headers'

class Contact::GovukController < ContactController
  before_filter proc {
    response.headers[Slimmer::Headers::REPORT_A_PROBLEM_FORM] = "false"
  }, only: [ :anonymous_feedback_thankyou, :named_contact_thankyou ]

  def anonymous_feedback_thankyou
  end

  def named_contact_thankyou
  end

  private
  def ticket_class
    ContactTicket
  end

  def type
    :contact
  end
end
