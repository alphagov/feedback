class EmailSurveySignup
  include ActiveModel::Validations
  attr_accessor :survey_id, :email_address, :ga_client_id
  attr_reader :survey_source

  validates :email_address,
            presence: true,
            email: { message: "The email address must be valid" },
            length: { maximum: 1250 }
  validates :survey_source,
            presence: true,
            length: { maximum: 2048 }
  validates :survey_id,
            presence: true,
            inclusion: { in: ->(_instance) { EmailSurvey.all.map(&:id) } }
  validate :survey_is_active, if: :survey
  validate :survey_source_is_relative, if: :survey_source

  def initialize(attributes = {})
    attributes.each do |key, value|
      send("#{key}=", value) if respond_to? "#{key}="
    end
  end

  def spam?
    false
  end

  def save
    Rails.application.config.survey_notify_service.send_email(self) if valid?
  end

  def survey_source=(new_survey_source)
    @survey_source = UrlNormaliser.relative_to_website_root(new_survey_source)
  end

  def survey_name
    survey.name if survey.present?
  end

  def survey_url
    return nil if survey.blank?

    uri = URI.parse(survey.url)
    query_string = "c=#{CGI.escape(survey_source)}"
    query_string += "&gcl=#{ga_client_id}" if ga_client_id.present?
    query_string.prepend("#{uri.query}&") if uri.query.present?
    uri.query = query_string
    uri.to_s
  end

  def survey
    @survey ||= EmailSurvey.find(survey_id)
  rescue EmailSurvey::NotFoundError
    nil
  end

  def to_notify_params
    {
      # this is our default template for emails, a future version might
      # want to make this configurable per survey, but then we'd almost
      # certainly need to make the `personalisation` parts configurable too
      template_id: template_id,
      email_address: email_address,
      personalisation: {
        # Note that notify will error if we don't supply all the keys the
        # template uses, but it will also error if we supply extra keys the
        # template doesn't use.  Take care here.
        survey_url: survey_url,
      },
      reference: "email-survey-signup-#{object_id}",
    }
  end

private

  def template_id
    @template_id ||= ENV.fetch("GOVUK_NOTIFY_TEMPLATE_ID", "fake-test-template-id")
  end

  def survey_source_is_relative
    errors.add(:survey_source, :is_not_a_relative_url) unless UrlNormaliser.valid_url?(survey_source, relative_only: true)
  end

  def survey_is_active
    errors.add(:survey_id, :is_not_currently_running) unless survey.active?
  end
end
