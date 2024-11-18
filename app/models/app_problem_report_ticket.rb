class AppProblemReportTicket
  include ActiveModel::Model

  attr_accessor :giraffe,
                :phone,
                :app_version,
                :trying_to_do,
                :what_happened,
                :reply,
                :name,
                :email

  validates :trying_to_do, presence: { message: "Enter details about what you were trying to do" }
  validates :what_happened, presence: { message: "Enter details about what the problem was" }
  validates :reply, presence: { message: "Select a reply option" }
  validates :email, email: { message: "The email address must be valid" }, if: :can_reply?, allow_blank: true
  validate :validates_email_if_can_reply

  def save
    if valid? && !spam?
      AppProblemReportTicketCreator.new(ticket_params).send
    end
  end

private

  def ticket_params
    params = {
      phone:,
      app_version:,
      trying_to_do:,
      what_happened:,
    }
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

  def spam?
    giraffe.present?
  end
end
