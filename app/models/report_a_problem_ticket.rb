class ReportAProblemTicket < Ticket
  SOURCE_WHITELIST = %w(mainstream inside_government page_not_found)

  attr_accessor :what_wrong, :what_doing, :url, :user_agent, :javascript_enabled, :referrer, :source, :page_owner

  validates :what_wrong, :presence => true, :if => proc{|ticket| ticket.what_doing.blank? }
  validates :what_doing, :presence => true, :if => proc{|ticket| ticket.what_wrong.blank? }

  def tags
    ['report_a_problem', source_tag, page_owner_tag].compact
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

  def page_owner_tag
    "page_owner/#{page_owner}" if page_owner && page_owner.match(/^[a-zA-Z0-9_]*$/)
  end

  def path_for_url
    uri = URI.parse(url)
    uri.path.presence || "Unknown page"
  rescue URI::InvalidURIError
    "Unknown page"
  end
end
