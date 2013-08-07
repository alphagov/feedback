class FoiTicket < Ticket

  attr_accessor :textdetails, :name, :email, :verifyemail

  validates_presence_of :name, :message => "The name field cannot be empty"
  validates_presence_of :email, :message => "The email field cannot be empty"
  validates_format_of :email, :with => /\A[\w\d]+[^@]*@[\w\d]+[^@]*\.[\w\d]+[^@]*\z/, :message => "The email address must be valid"
  validates_confirmation_of :email, :message => "The two email addresses must match"
  validates_presence_of :textdetails, :message => "The message field cannot be empty"
  validates_length_of :textdetails, :maximum => FIELD_MAXIMUM_CHARACTER_COUNT, :message => "The message field can be max #{FIELD_MAXIMUM_CHARACTER_COUNT} characters"

  def save
    TicketClient.raise_foi_request(create_ticket) if valid?
  end

  private
  def create_ticket
    { requester: { name: name, email: email }, details: textdetails }
  end
end
