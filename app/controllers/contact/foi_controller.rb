class Contact::FoiController < ContactController
  private
  def ticket_class
    FoiTicket
  end

  def type
    :foi
  end
end
