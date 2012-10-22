class ReportAProblemTicket < Ticket

  attr_accessor :what_wrong, :what_doing, :url, :user_agent, :javascript_enabled

  private

  def create_ticket
    description = report_a_problem_format_description
    ticket = {
      :subject => path_for_url(url),
      :tags => ['report_a_problem'],
      :description => description
    }
  end

  def report_a_problem_format_description
    description = <<-EOT
url: #{url}
what_doing: #{what_doing}
what_wrong: #{what_wrong}
user_agent: #{user_agent || 'unknown'}
javascript_enabled: #{javascript_enabled == "true"}
EOT
  end

  def path_for_url(url)
    uri = URI.parse(url)
    uri.path.presence || "Unknown page"
  rescue URI::InvalidURIError
    "Unknown page"
  end
end
