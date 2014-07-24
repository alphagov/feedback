require 'gds_api/support'

class FoiTicket < Ticket

  attr_accessor :textdetails, :name, :email, :verifyemail

  validates_presence_of :name, :message => "The name field cannot be empty"
  validates_presence_of :email, :message => "The email field cannot be empty"
  validates_format_of :email, :with => /\A[\w\d]+[^@]*@[\w\d]+[^@]*\.[\w\d]+[^@]*\z/, :message => "The email address must be valid"
  validates_confirmation_of :email, :message => "The two email addresses must match"
  validates_presence_of :textdetails, :message => "The message field cannot be empty"
  validates_length_of :textdetails, :maximum => FIELD_MAXIMUM_CHARACTER_COUNT, :message => "The message field can be max #{FIELD_MAXIMUM_CHARACTER_COUNT} characters"

  def save
    if valid?
      Feedback.support.create_foi_request(ticket_details)
    end
  end

  private
  def ticket_details
    { requester: { name: name, email: email }, details: textdetails, url: url }
  end
end
