class Ticket
  include ActiveModel::Validations
  attr_accessor :val, :user_agent

  # This is deliberately higher than the max character count
  # in the front-end (javascript and maxlength in the markup),
  # because certain browsers treat "\r\n" incorrectly as
  # 1 character long.
  FIELD_MAXIMUM_CHARACTER_COUNT = 1250

  validate :validate_val

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
      ticket = create_ticket
      ticket_client.raise_ticket(ticket)
    end
    ticket
  end

  def spam?
    errors[:val] && errors[:val].any?
  end

  private
  def ticket_client
    @ticket_client ||= TicketClientConnection.get_client
  end

  def validate_val
    # val is used as a naive bot-preventor
    unless val.blank?
      @errors.add :val
    end
  end
end
