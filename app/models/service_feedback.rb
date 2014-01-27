require 'gds_api/support'

class ServiceFeedback < Ticket
  attr_accessor :service_satisfaction_rating, :improvement_comments, :slug, :javascript_enabled, :url

  validates_presence_of :service_satisfaction_rating, message: "You must select a rating"
  validates_inclusion_of :service_satisfaction_rating, in: ('1'..'5').to_a
  validates_length_of :improvement_comments, maximum: FIELD_MAXIMUM_CHARACTER_COUNT, message: "The message field can be max #{FIELD_MAXIMUM_CHARACTER_COUNT} characters"
  validates_length_of :slug, maximum: 512
  validates_length_of :url, maximum: 2048

  def save
    if valid?
      support_api = GdsApi::Support.new(SUPPORT_API[:url], bearer_token: SUPPORT_API[:bearer_token])
      support_api.create_service_feedback(details, headers: { "X-Varnish" => varnish_id })
    end
  end

  def details
    { 
      service_satisfaction_rating: service_satisfaction_rating.to_i,
      improvement_comments: improvement_comments,
      slug: slug, 
      user_agent: user_agent,
      javascript_enabled: !!javascript_enabled,
      url: url_if_valid(@url)
    }
  end
end
