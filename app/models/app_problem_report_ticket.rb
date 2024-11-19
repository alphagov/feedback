class AppProblemReportTicket < AppTicket
  include ReplyValidation

  attr_accessor :phone,
                :app_version,
                :trying_to_do,
                :what_happened

  validates :trying_to_do, presence: { message: "Enter details about what you were trying to do" }
  validates :what_happened, presence: { message: "Enter details about what the problem was" }

  validates :phone, length: {
    maximum: MAX_FIELD_CHARACTERS,
    message: "Details about your phone must be #{MAX_FIELD_CHARACTERS} characters or less",
  }
  validates :app_version, length: {
    maximum: MAX_FIELD_CHARACTERS,
    message: "The app version must be #{MAX_FIELD_CHARACTERS} characters or less",
  }
  validates :trying_to_do, length: {
    maximum: MAX_FIELD_CHARACTERS,
    message: "Details about what you were trying to do must be #{MAX_FIELD_CHARACTERS} characters or less",
  }
  validates :what_happened, length: {
    maximum: MAX_FIELD_CHARACTERS,
    message: "Details about what the problem was must be #{MAX_FIELD_CHARACTERS} characters or less",
  }

  def save
    AppProblemReportTicketCreator.new(ticket_params).send if valid_ticket?
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
end
