class Contact::GovukController < ContactController
  private
  def ticket_class
    ContactTicket
  end

  def type
    :contact
  end
end
