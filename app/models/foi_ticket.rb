class FoiTicket < Ticket

  attr_accessor :textdetails, :name, :email, :verifyemail, :controller, :action

  validates_presence_of :textdetails, :message => "The message field cannot be empty"
  validates_presence_of :email, :message => "The email field cannot be empty"
  validates_presence_of :name, :message => "The name field cannot be empty"
  validates_format_of :email, :with => /^[\w\d]+[^@]*@[\w\d]+[^@]*\.[\w\d]+[^@]*$/, :message => "The email address must be valid"
  validates_length_of :textdetails, :maximum => 1200, :message => "The message field can be max 1200 characters"
  validates_confirmation_of :email, :message => "The two email addresses must match"

  private

  def foi_ticket_description
    description = ""
    unless name.blank?
      description += "[Name]\n" + name + "\n"
    end
    description += "[Details]\n" + textdetails
  end

  def create_ticket
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
