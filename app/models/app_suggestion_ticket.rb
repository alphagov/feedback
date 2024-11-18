class AppSuggestionTicket
  include ActiveModel::Model

  attr_accessor :giraffe,
                :details,
                :reply,
                :name,
                :email

  validates :details, presence: { message: "Enter your suggestion" }
  validates :reply, presence: { message: "Select a reply option" }
  validates :email, email: { message: "The email address must be valid" }, if: :can_reply?, allow_blank: true
  validate :validates_email_if_can_reply

  def save
    if valid?
      AppSuggestionTicketCreator.new(ticket_params).send
    end
  end

private

  def ticket_params
    params = { details: }
    params[:requester] = { name:, email: } if can_reply?
    params
  end

  def can_reply?
    reply == "yes"
  end

  def validates_email_if_can_reply
    if can_reply? && email.blank?
      errors.add(:email, "Please add an email address")
    end
  end
end
