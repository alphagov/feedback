class Ticket
  include ActiveModel::Validations

  def initialize(attributes = {})
    attributes.each do |key, value|
      if respond_to? "#{key}="
        send("#{key}=", value)
      end
    end
    valid?
  end

  def save
    ticket = nil
    if valid?
      begin
        ticket = create_ticket
        ticket_client.raise_ticket(ticket)
      rescue => e
        ticket = nil
        @errors.add :connection, "Connection error"
        ExceptionNotifier::Notifier.background_exception_notification(e).deliver
      end
    end
    ticket
  end
  private

  def ticket_client
    @ticket_client ||= TicketClientConnection.get_client
  end
end
