require "uri"
require "gds_api/support_api"

class ServiceFeedback < Ticket
  attr_accessor :service_satisfaction_rating, :slug, :javascript_enabled, :referrer
  attr_writer :improvement_comments

  validates :service_satisfaction_rating, presence: { message: "You must select a rating" }
  validates :service_satisfaction_rating, inclusion: { in: ("1".."5").to_a }
  validates :improvement_comments, length: { maximum: FIELD_MAXIMUM_CHARACTER_COUNT, message: "The message field can be max #{FIELD_MAXIMUM_CHARACTER_COUNT} characters" }
  validates :slug, length: { maximum: 512 }

  def improvement_comments
    @improvement_comments.presence
  end

  def save
    Rails.application.config.support_api.create_service_feedback(options) if valid?
  end

  def options
    {
      service_satisfaction_rating: service_satisfaction_rating.to_i,
      details: improvement_comments,
      slug: slug,
      user_agent: user_agent,
      javascript_enabled: !!javascript_enabled,
      referrer: referrer,
      path: path,
      url: url,
    }
  end

private

  def path
    !url.nil? ? URI(url).path : nil
  end
end
