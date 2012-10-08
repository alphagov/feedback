class FoiTicket < Ticket

  attr_accessor :textdetails, :name, :email, :verifyemail, :controller, :action

  validates_presence_of :textdetails, :message => "The message field cannot be empty"
  validates_presence_of :email, :message => "The email field cannot be empty"
  validates_presence_of :name, :message => "The name field cannot be empty"
  validates_format_of :email, :with => /^[\w\d]+[^@]*@[\w\d]+[^@]*\.[\w\d]+[^@]*$/, :message => "The email address must be valid"
  validates_length_of :textdetails, :maximum => 1200, :message => "The message field can be max 1200 characters"
  validates_confirmation_of :email, :message => "The two email addresses must match"

  def initialize(attributes = {})
    attributes.each do |key, value|
      send("#{key}=", value)
    end
    valid?
  end

  def save
    ticket = nil
    if valid?
      begin
        ticket = foi_ticket
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

  def foi_ticket_description
    description = ""
    unless name.blank?
      description += "[Name]\n" + name + "\n"
    end
    description += "[Details]\n" + textdetails
  end

  def foi_ticket
    description = foi_ticket_description
    ticket = {
      :subject => "FOI",
      :tags => ["FOI_request"],
      :name => name,
      :email => email,
      :description => description
    }
  end
end
