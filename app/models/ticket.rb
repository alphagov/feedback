class Ticket
  include ActiveModel::Validations

  private

  def ticket_client
    @ticket_client ||= TicketClientConnection.get_client
  end
end
