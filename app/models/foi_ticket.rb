require 'ticket_client_connection'
require 'foi_validator'

class FoiTicket
  def initialize(params)
    @params = params
    @errors = {}
  end

  def save
    validator = FoiValidator.new @params
    @errors = validator.validate
    if @errors.empty?
      begin
        ticket = foi_ticket @params
        ticket_client.raise_ticket(ticket)
        true
      rescue => e
        @errors[:connection] = "Connection error"
        ExceptionNotifier::Notifier.background_exception_notification(e).deliver
        false
      end
    end
  end

  def errors
    @errors
  end

  private

  def ticket_client
    @ticket_client ||= TicketClientConnection.get_client
  end

  def foi_ticket_description(params)
    description = ""
    unless params[:name].blank?
      description += "[Name]\n" + params[:name] + "\n"
    end
    unless params[:textdetails].blank?
      description += "[Details]\n" + params[:textdetails]
    end
    description
  end

  def foi_ticket(params)
    description = foi_ticket_description params
    ticket = {
      :subject => "FOI",
      :tags => ["FOI_request"],
      :name => params[:name],
      :email => params[:email],
      :description => description
    }
  end
end
