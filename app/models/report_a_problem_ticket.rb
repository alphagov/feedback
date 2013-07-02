class ReportAProblemTicket < Ticket
  SOURCE_WHITELIST = %w(citizen government specialist)

  attr_accessor :what_wrong, :what_doing, :url, :user_agent, :javascript_enabled, :referrer, :source

  validates :what_wrong, :presence => true, :if => proc{|ticket| ticket.what_doing.blank? }
  validates :what_doing, :presence => true, :if => proc{|ticket| ticket.what_wrong.blank? }

  def tags
    ['report_a_problem', source_tag].compact
  end

  private

  def create_ticket
    description = report_a_problem_format_description
    ticket = {
      :subject => path_for_url,
      :tags => tags,
      :description => description
    }
  end

  def report_a_problem_format_description
    description = <<-EOT
url: #{url}
what_doing: #{what_doing}
what_wrong: #{what_wrong}
user_agent: #{user_agent || 'unknown'}
referrer: #{referrer || 'unknown'}
javascript_enabled: #{javascript_enabled == "true"}
EOT
  end

  def source_tag
    source if SOURCE_WHITELIST.include?(source)
  end

  def path_for_url
    uri = URI.parse(url)
    uri.path.presence || "Unknown page"
  rescue URI::InvalidURIError
    "Unknown page"
  end
end
