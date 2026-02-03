class AppChatFeedbackTicket < AppTicket
  include ReplyValidation

  attr_accessor :feedback

  validates :feedback, presence: { message: "Enter your feedback" }
  validates :feedback, length: {
    maximum: MAX_FIELD_CHARACTERS,
    message: "Your feedback must be #{MAX_FIELD_CHARACTERS} characters or less",
  }

  def save
    AppChatFeedbackTicketCreator.new(ticket_params).send if valid_ticket?
  end

private

  def ticket_params
    named = name.presence || "Not submitted"
    params = { feedback: }
    params[:requester] = { name: named, email: } if can_reply?
    params
  end
end
