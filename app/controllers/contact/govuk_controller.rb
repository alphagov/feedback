class Contact::GovukController < ContactController
  def anonymous_feedback_thankyou    
  end

  private
  def ticket_class
    ContactTicket
  end

  def type
    :contact
  end
end
