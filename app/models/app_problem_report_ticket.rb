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

  def save
    if valid?
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
    params[:requester] = { name:, email: } unless anonymous?
    params
  end

  def anonymous?
    reply == "no"
  end
end
