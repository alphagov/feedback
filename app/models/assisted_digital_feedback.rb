require "uri"

class AssistedDigitalFeedback < Ticket
  attr_accessor :assistance_received,
                :assistance_provided_by,
                :assistance_provided_by_other,
                :assistance_satisfaction_rating,
                :service_satisfaction_rating,
                :slug,
                :javascript_enabled

  attr_writer :improvement_comments,
              :assistance_received_comments,
              :assistance_improvement_comments

  validates :assistance_received,
            presence: { message: "You must select if you received assistance with this service" },
            inclusion: { in: %w[yes no] }

  validates :assistance_received_comments,
            length: {
              maximum: FIELD_MAXIMUM_CHARACTER_COUNT,
              message: "The message field can be max #{FIELD_MAXIMUM_CHARACTER_COUNT} characters",
            },
            presence: true,
            if: :assistance_received?

  validates :assistance_provided_by,
            inclusion: { in: %w[friend-relative work-colleague government-staff other] },
            presence: true,
            if: :assistance_received?

  validates :assistance_provided_by_other,
            length: { maximum: 512 },
            presence: true,
            if: :assistance_provided_by_other?

  validates :assistance_satisfaction_rating,
            inclusion: { in: ("1".."5").to_a },
            presence: true,
            if: :assistance_provided_by_other_or_government_staff?

  validates :assistance_improvement_comments,
            length: {
              maximum: FIELD_MAXIMUM_CHARACTER_COUNT,
              message: "The message field can be max #{FIELD_MAXIMUM_CHARACTER_COUNT} characters",
            },
            if: :assistance_provided_by_other_or_government_staff?

  validates :service_satisfaction_rating,
            presence: { message: "You must select a rating" },
            inclusion: { in: ("1".."5").to_a }

  validates :improvement_comments,
            length: {
              maximum: FIELD_MAXIMUM_CHARACTER_COUNT,
              message: "The message field can be max #{FIELD_MAXIMUM_CHARACTER_COUNT} characters",
            }

  validates :slug, length: { maximum: 512 }

  def initialize(*args)
    super(*args)
    @created_at = Time.current
  end

  def save
    Rails.application.config.assisted_digital_spreadsheet.store(as_row_data) if valid?
  end

  def as_row_data
    [
      assistance_received,
      assistance_received? ? assistance_received_comments : nil,
      assistance_received? ? assistance_provided_by : nil,
      assistance_provided_by_other? ? assistance_provided_by_other : nil,
      assistance_provided_by_other_or_government_staff? ? assistance_satisfaction_rating.to_i : nil,
      assistance_provided_by_other_or_government_staff? ? assistance_improvement_comments : nil,
      service_satisfaction_rating.to_i,
      improvement_comments,
      slug,
      user_agent,
      javascript_enabled.present?,
      referrer,
      path,
      url,
      created_at,
    ]
  end

  def assistance_received_comments
    @assistance_received_comments.presence
  end

  def assistance_improvement_comments
    @assistance_improvement_comments.presence
  end

  def improvement_comments
    @improvement_comments.presence
  end

private

  attr_reader :created_at

  def assistance_received?
    assistance_received.present? && assistance_received == "yes"
  end

  def assistance_provided_by_other?
    assistance_received? ? assistance_provided_by.present? && assistance_provided_by == "other" : false
  end

  def assistance_provided_by_other_or_government_staff?
    assistance_received? ? assistance_provided_by.present? && %w[government-staff other].include?(assistance_provided_by) : false
  end

  def path
    !url.nil? ? URI(url).path : nil
  end
end
