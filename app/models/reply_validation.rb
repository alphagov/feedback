module ReplyValidation
  extend ActiveSupport::Concern

  attr_accessor :reply, :name, :email

  included do
    validates :reply, presence: { message: "Select yes if you want a reply" }
    validates :email, email: { message: "Enter an email address in the correct format, like name@example.com" },
                      if: :can_reply?,
                      allow_blank: true
    validate :validates_email_if_can_reply

    validates :email, length: {
      maximum: AppTicket::MAX_FIELD_CHARACTERS,
      message: "Your email address must be #{AppTicket::MAX_FIELD_CHARACTERS} characters or less",
    }
    validates :name, length: {
      maximum: AppTicket::MAX_FIELD_CHARACTERS,
      message: "Your name must be #{AppTicket::MAX_FIELD_CHARACTERS} characters or less",
    }
  end

private

  def can_reply?
    reply == "yes"
  end

  def validates_email_if_can_reply
    if can_reply? && email.blank?
      errors.add(:email, "Enter an email address")
    end
  end
end
