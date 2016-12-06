require 'uri'

class AssistedDigitalHelpWithFeesFeedback < Ticket
  attr_accessor :assistance, :service_satisfaction_rating, :improvement_comments, :slug, :javascript_enabled

  validates :assistance, presence: { message: "You must select how much assistance you received" },
                         inclusion: { in: %w(no some all) }
  validates :service_satisfaction_rating, presence: { message: "You must select a rating" },
                                          inclusion: { in: ('1'..'5').to_a }
  validates :improvement_comments, length: { maximum: FIELD_MAXIMUM_CHARACTER_COUNT, message: "The message field can be max #{FIELD_MAXIMUM_CHARACTER_COUNT} characters" }
  validates :slug, length: { maximum: 512 }

  def initialize(*args)
    super(*args)
    @created_at = Time.current
  end

  def save
    Feedback.assisted_digital_help_with_fees_spreadsheet.store(as_row_data) if valid?
  end

  def as_row_data
    [
      assistance,
      service_satisfaction_rating.to_i,
      improvement_comments,
      slug,
      user_agent,
      !!javascript_enabled,
      referrer,
      path,
      url,
      created_at,
    ]
  end

private

  attr_reader :created_at

  def improvement_comments
    @improvement_comments.present? ? @improvement_comments : nil
  end

  def path
    !url.nil? ? URI(url).path : nil
  end
end
