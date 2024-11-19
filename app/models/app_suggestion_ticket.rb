class AppSuggestionTicket < AppTicket
  include ReplyValidation

  attr_accessor :details

  validates :details, presence: { message: "Enter your suggestion" }
  validates :details, length: {
    maximum: MAX_FIELD_CHARACTERS,
    message: "Your suggestion must be #{MAX_FIELD_CHARACTERS} characters or less",
  }

  def save
    AppSuggestionTicketCreator.new(ticket_params).send if valid_ticket?
  end

private

  def ticket_params
    params = { details: }
    params[:requester] = { name:, email: } if can_reply?
    params
  end
end
