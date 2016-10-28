require 'uri'

class AssistedDigitalHelpWithFeesFeedback < Ticket
  attr_accessor :assistance, :service_satisfaction_rating, :improvement_comments, :slug, :javascript_enabled

  validates :assistance, presence: { message: "You must select how much assistance you received" },
                         inclusion: { in: %w(no some all) }
  validates :service_satisfaction_rating, presence: { message: "You must select a rating" },
                                          inclusion: { in: ('1'..'5').to_a }
  validates :improvement_comments, length: { maximum: FIELD_MAXIMUM_CHARACTER_COUNT, message: "The message field can be max #{FIELD_MAXIMUM_CHARACTER_COUNT} characters" }
  validates :slug, length: { maximum: 512 }

  def save
  end

  def options
    {
      assistance: assistance,
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

  def improvement_comments
    @improvement_comments.present? ? @improvement_comments : nil
  end

  def path
    !url.nil? ? URI(url).path : nil
  end
end
