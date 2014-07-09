require 'gds_api/support'

class ReportAProblemTicket < Ticket
  SOURCE_WHITELIST = %w(mainstream inside_government page_not_found)

  attr_accessor :what_wrong, :what_doing, :javascript_enabled, :referrer, :source, :page_owner

  validates :what_wrong, :presence => true, :if => proc{|ticket| ticket.what_doing.blank? }
  validates :what_doing, :presence => true, :if => proc{|ticket| ticket.what_wrong.blank? }

  def save
    if valid? && !spam?
      support_api = GdsApi::Support.new(SUPPORT_API[:url], bearer_token: SUPPORT_API[:bearer_token])
      support_api.create_problem_report(ticket_details)
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

  def referrer=(new_referrer)
    @referrer = (new_referrer == 'unknown' ? nil : new_referrer)
  end

  def referrer
    url_if_valid(@referrer)
  end

  def spam?
    PROBLEM_REPORT_SPAM_MATCHERS.any? { |pattern| pattern[self] }
  end

  private
  def ticket_details
    [:what_wrong, :what_doing, :url, :user_agent, :javascript_enabled, :referrer, :source, :page_owner].inject({}) do |details, field|
      details[field] = send(field)
      details
    end
  end
end
