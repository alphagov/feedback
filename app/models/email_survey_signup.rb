class EmailSurveySignup
  include ActiveModel::Validations
  attr_accessor :survey_id, :survey_source, :email_address

  validates :email_address, presence: true,
                            email: { message: "The email address must be valid" },
                            length: { maximum: 1250 }
  validates :survey_source, presence: true,
                            length: { maximum: 2048 }
  validates :survey_id, presence: true,
                        inclusion: { in: ->(_instance) { EmailSurvey.all.map(&:id) } }
  validate :survey_is_active, if: :survey

  def initialize(attributes = {})
    attributes.each do |key, value|
      send("#{key}=", value) if respond_to? "#{key}="
    end
    valid?
  end

  def spam?
    false
  end

  def survey_source
    UrlNormaliser.url_if_valid(@survey_source)
  end

  def survey
    @survey ||= EmailSurvey.find(survey_id)
  end

private

  def survey_is_active
    errors.add(:survey_id, :is_not_currently_running) unless survey.active?
  end
end
