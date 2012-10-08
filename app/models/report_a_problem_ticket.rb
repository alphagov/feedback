class ReportAProblemTicket < Ticket

  attr_accessor :what_wrong, :what_doing, :url, :controller, :action

  def initialize(attributes = {})
    attributes.each do |key, value|
      send("#{key}=", value)
    end
    valid?
  end

  def save
    ticket = nil
    begin
      ticket = report_a_problem_ticket
      ticket_client.raise_ticket(ticket)
    rescue => e
      ticket = nil
      @errors.add :connection, "Connection error"
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver
    end
    ticket
  end

  private

  def report_a_problem_ticket
    description = report_a_problem_format_description
    ticket = {
      :subject => path_for_url(url),
      :tags => ['report_a_problem'],
      :description => description
    }
  end

  def report_a_problem_format_description
    description = "url: #{url}\n" +
    "what_doing: #{what_doing}\n" +
    "what_wrong: #{what_wrong}"
  end

  def path_for_url(url)
    uri = URI.parse(url)
    uri.path.presence || "Unknown page"
  rescue URI::InvalidURIError
    "Unknown page"
  end
end
