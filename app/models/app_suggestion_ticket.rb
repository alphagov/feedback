class AppSuggestionTicket
  include ActiveModel::Model

  attr_accessor :giraffe,
                :details,
                :reply,
                :name,
                :email

  def save
    if valid?
      AppSuggestionTicketCreator.new(ticket_params).send
    end
  end

private

  def ticket_params
    params = { details: }
    params[:requester] = { name:, email: } unless anonymous?
    params
  end

  def anonymous?
    reply == "no"
  end
end
