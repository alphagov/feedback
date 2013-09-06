class ReportAProblemTicket < Ticket
  SOURCE_WHITELIST = %w(mainstream inside_government page_not_found)

  attr_accessor :what_wrong, :what_doing, :url, :javascript_enabled, :referrer, :source, :page_owner

  validates :what_wrong, :presence => true, :if => proc{|ticket| ticket.what_doing.blank? }
  validates :what_doing, :presence => true, :if => proc{|ticket| ticket.what_wrong.blank? }

  def save
    if valid?
      support_api = GdsApi::Support.new(SUPPORT_API[:url], bearer_token: SUPPORT_API[:bearer_token])
      support_api.create_problem_report(ticket_details, headers: { "X-Varnish" => varnish_id })
    end
  end

  def source
    @source if SOURCE_WHITELIST.include?(@source)
  end

  def page_owner
    @page_owner && @page_owner.match(/^[a-zA-Z0-9_]+$/) ? @page_owner : nil
  end

  def javascript_enabled
    @javascript_enabled == "true"
  end

  def url
    url_if_valid(@url)
  end

  def referrer
    url_if_valid(@referrer)
  end

  private
  def ticket_details
    [:what_wrong, :what_doing, :url, :user_agent, :javascript_enabled, :referrer, :source, :page_owner].inject({}) do |details, field|
      details[field] = send(field)
      details
    end
  end

  def url_if_valid(candidate)
    valid_url?(candidate) ? candidate : nil
  end

  def valid_url?(candidate)
    url = URI.parse(candidate) rescue false
    url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS)
  end
end
