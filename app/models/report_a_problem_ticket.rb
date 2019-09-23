require "gds_api/support"

class ReportAProblemTicket < Ticket
  SOURCE_WHITELIST = %w(mainstream inside_government page_not_found).freeze

  attr_accessor :what_wrong, :what_doing, :referrer
  attr_writer :page_owner, :javascript_enabled, :source

  validates :what_wrong, presence: true, if: proc { |ticket| ticket.what_doing.blank? }
  validates :what_doing, presence: true, if: proc { |ticket| ticket.what_wrong.blank? }

  def save
    if valid? && !spam?
      Rails.application.config.support_api.create_problem_report(ticket_details)
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

  def spam?
    Rails.application.config.problem_report_spam_matchers.any? { |pattern| pattern[self] }
  end

private

  def ticket_details
    %i[what_wrong what_doing path user_agent javascript_enabled referrer source page_owner].inject({}) do |details, field|
      details[field] = send(field)
      details
    end
  end
end
