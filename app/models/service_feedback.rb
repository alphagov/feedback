require 'uri'
require 'gds_api/support_api'

class ServiceFeedback < Ticket
  attr_accessor :service_satisfaction_rating, :improvement_comments, :slug, :javascript_enabled, :referrer

  validates_presence_of :service_satisfaction_rating, message: "You must select a rating"
  validates_inclusion_of :service_satisfaction_rating, in: ('1'..'5').to_a
  validates_length_of :improvement_comments, maximum: FIELD_MAXIMUM_CHARACTER_COUNT, message: "The message field can be max #{FIELD_MAXIMUM_CHARACTER_COUNT} characters"
  validates_length_of :slug, maximum: 512

  def save
    if valid?
      Feedback.support_api.create_service_feedback(options)
    end
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
    }
  end

  private
  def improvement_comments
    @improvement_comments.present? ? @improvement_comments : nil
  end

  def path
    !url.nil? ? URI(url).path : nil
  end
end
