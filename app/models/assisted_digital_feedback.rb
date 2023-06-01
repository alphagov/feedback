require "uri"

class AssistedDigitalFeedback < Ticket
  attr_accessor :assistance_received,
                :assistance_provided_by,
                :assistance_provided_by_other,
                :assistance_satisfaction_rating,
                :assistance_satisfaction_rating_other,
                :service_satisfaction_rating,
                :slug,
                :javascript_enabled

  attr_writer :improvement_comments,
              :assistance_received_comments,
              :assistance_improvement_comments,
              :assistance_improvement_comments_other

  validates :assistance_received,
            presence: { message: I18n.translate("activemodel.errors.models.assisted_digital_feedback.select_assistance_received") },
            inclusion: { in: %w[yes no] }

  validates :assistance_received_comments,
            length: {
              maximum: FIELD_MAXIMUM_CHARACTER_COUNT,
              message: I18n.translate("activemodel.errors.models.assisted_digital_feedback.max_character_count", field_maximum_character_count: FIELD_MAXIMUM_CHARACTER_COUNT),
            },
            presence: { message: I18n.translate("activemodel.errors.models.assisted_digital_feedback.cant_be_blank") },
            if: :assistance_received?

  validates :assistance_provided_by,
            presence: { message: I18n.translate("activemodel.errors.models.assisted_digital_feedback.cant_be_blank") },
            inclusion: { in: %w[friend-relative work-colleague government-staff other] },
            if: :assistance_received?

  validates :assistance_provided_by_other,
            presence: { message: I18n.translate("activemodel.errors.models.assisted_digital_feedback.cant_be_blank") },
            length: { maximum: 512 },
            if: :assistance_provided_by_other?

  validates :assistance_satisfaction_rating,
            presence: { message: I18n.translate("activemodel.errors.models.assisted_digital_feedback.select_rating") },
            inclusion: { in: ("1".."5").to_a },
            if: :assistance_provided_by_government_staff?

  validates :assistance_satisfaction_rating_other,
            presence: { message: I18n.translate("activemodel.errors.models.assisted_digital_feedback.select_rating") },
            inclusion: { in: ("1".."5").to_a },
            if: :assistance_provided_by_other?

  validates :assistance_improvement_comments,
            length: {
              maximum: FIELD_MAXIMUM_CHARACTER_COUNT,
              message: I18n.translate("activemodel.errors.models.assisted_digital_feedback.max_character_count", field_maximum_character_count: FIELD_MAXIMUM_CHARACTER_COUNT),
            },
            if: :assistance_provided_by_government_staff?

  validates :assistance_improvement_comments_other,
            length: {
              maximum: FIELD_MAXIMUM_CHARACTER_COUNT,
              message: I18n.translate("activemodel.errors.models.assisted_digital_feedback.max_character_count", field_maximum_character_count: FIELD_MAXIMUM_CHARACTER_COUNT),
            },
            if: :assistance_provided_by_other?

  validates :service_satisfaction_rating,
            presence: { message: I18n.translate("activemodel.errors.models.assisted_digital_feedback.select_rating") },
            inclusion: { in: ("1".."5").to_a }

  validates :improvement_comments,
            length: {
              maximum: FIELD_MAXIMUM_CHARACTER_COUNT,
              message: I18n.translate("activemodel.errors.models.assisted_digital_feedback.max_character_count", field_maximum_character_count: FIELD_MAXIMUM_CHARACTER_COUNT),
            }

  validates :slug, length: { maximum: 512 }

  def initialize(*args)
    super(*args)
    @created_at = Time.zone.now
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
      assistance_satisfaction_rating_row_data,
      assistance_improvement_comments_row_data,
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

  def assistance_improvement_comments_other
    @assistance_improvement_comments_other.presence
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

  def assistance_provided_by_government_staff?
    assistance_received? ? assistance_provided_by.present? && assistance_provided_by == "government-staff" : false
  end

  def path
    !url.nil? ? URI(url).path : nil
  end

  def assistance_satisfaction_rating_row_data
    if assistance_provided_by_government_staff?
      assistance_satisfaction_rating.to_i
    elsif assistance_provided_by_other?
      assistance_satisfaction_rating_other.to_i
    end
  end

  def assistance_improvement_comments_row_data
    if assistance_provided_by_government_staff?
      assistance_improvement_comments
    elsif assistance_provided_by_other?
      assistance_improvement_comments_other
    end
  end
end
