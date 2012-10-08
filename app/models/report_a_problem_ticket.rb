class ReportAProblemTicket
  def initialize(params)
    @params = params
    @errors = {}
  end

  def save
    begin
      ticket = report_a_problem_ticket @params
      ticket_client.raise_ticket(ticket)
      true
    rescue => e
      @errors[:connection] = "Connection error"
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver
      false
    end
  end

  def errors
    @errors
  end

  private

  def ticket_client
    @ticket_client ||= TicketClientConnection.get_client
  end

  def report_a_problem_ticket(params)
    description = report_a_problem_format_description params
    ticket = {
      :subject => path_for_url(params[:url]),
      :tags => ['report_a_problem'],
      :description => description
    }
  end

  def report_a_problem_format_description(params)
    description = "url: #{params[:url]}\n" +
    "what_doing: #{params[:what_doing]}\n" +
    "what_wrong: #{params[:what_wrong]}"
  end

  def path_for_url(url)
    uri = URI.parse(url)
    uri.path.presence || "Unknown page"
  rescue URI::InvalidURIError
    "Unknown page"
  end
end
