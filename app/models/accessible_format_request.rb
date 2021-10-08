class AccessibleFormatRequest
  include ActiveModel::Validations
  attr_accessor :document_title, :publication_path, :format_type, :custom_details, :contact_name, :alternative_format_email, :contact_email

  validates :document_title, presence: true
  validates :publication_path, presence: true
  validates :format_type, presence: true
  validates :alternative_format_email,
            presence: true,
            email: { message: "The email address must be valid" }
  validates :contact_email,
            presence: true,
            email: { message: "The email address must be valid" }

  def initialize(attributes = {})
    attributes.each do |key, value|
      send("#{key}=", value)
    end
  end

  def to_notify_params
    {
      template_id: template_id,
      email_address: alternative_format_email,
      personalisation: {
        # Note that notify will error if we don't supply all the keys the
        # template uses, but it will also error if we supply extra keys the
        # template doesn't use.  Take care here.
        contact_name: contact_name,
        contact_email: contact_email,
        document_title: document_title,
        publication_path: publication_path,
        format_type: presented_format_type,
        custom_details: presented_custom_details,
      },
      reference: "accessible-format-request-#{object_id}",
      email_reply_to_id: reply_to_id,
    }
  end

private

  def presented_format_type
    format_type.gsub("-", " ").humanize
  end

  def presented_custom_details
    custom_details.presence || "Not provided"
  end

  def template_id
    @template_id ||= ENV.fetch("GOVUK_NOTIFY_ACCESSIBLE_FORMAT_REQUEST_TEMPLATE_ID", "fake-test-accessible-format-request-template-id")
  end

  def reply_to_id
    @reply_to_id ||= ENV.fetch("GOVUK_NOTIFY_ACCESSIBLE_FORMAT_REQUEST_REPLY_TO_ID", "fake-test-accessible-format-request-reply-to-id")
  end
end
