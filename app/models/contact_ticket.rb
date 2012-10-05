class ContactTicket
  def initialize(params)
    @params = params
    @errors = {}
  end

  def save
    validator = ContactValidator.new @params
    @errors = validator.validate
    if @errors.empty?
      begin
        ticket = contact_ticket(@params)
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

  REASON_HASH = {
    "cant-find" => {:subject => "I can't find", :tag => "i_cant_find"},
    "ask-question" => {:subject => "Ask a question", :tag => "ask_question"},
    "report-problem" => {:subject => "Report a problem", :tag => "report_a_problem_public"},
    "make-suggestion" => {:subject => "General feedback", :tag => "general_feedback"}
  }

  def ticket_client
    @ticket_client ||= TicketClientConnection.get_client
  end

  def contact_ticket_description(params)
    description = "[Location]\n" + params[:location]
    if (params[:location] == "specific") and (not params[:link].blank?)
      description += "\n[Link]\n" + params[:link]
    end
    unless params[:name].blank?
      description += "\n[Name]\n" + params[:name]
    end

    unless params[:textdetails].blank?
      description += "\n[Details]\n" + params[:textdetails]
    end
    description
  end

  def contact_ticket(params)
    ticket = {}
    if REASON_HASH[params["query-type"]]
      description = contact_ticket_description params
      subject = REASON_HASH[params["query-type"]][:subject]
      tag = REASON_HASH[params["query-type"]][:tag]
      ticket = {
        :subject => subject,
        :tags => [tag],
        :name => params[:name],
        :email => params[:email],
        :section => params[:section],
        :description => description
      }
    end
    ticket
  end
end
