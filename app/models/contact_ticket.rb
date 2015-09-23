require 'gds_api/support'

class ContactTicket < Ticket
  attr_accessor :location, :link, :textdetails,
                :name, :email,
                :javascript_enabled, :referrer

  validate :validate_link
  validates_length_of :link, maximum: FIELD_MAXIMUM_CHARACTER_COUNT, message: "The page field can be max #{FIELD_MAXIMUM_CHARACTER_COUNT} characters"
  validates_presence_of :textdetails, message: "The message field cannot be empty"
  validates_length_of :textdetails, maximum: FIELD_MAXIMUM_CHARACTER_COUNT, message: "The message field can be max #{FIELD_MAXIMUM_CHARACTER_COUNT} characters"
  validates_length_of :name, maximum: FIELD_MAXIMUM_CHARACTER_COUNT, message: "The name field can be max #{FIELD_MAXIMUM_CHARACTER_COUNT} characters"
  validates :email, email: { message: "The email address must be valid" }, allow_blank: true
  validates_length_of :email, maximum: FIELD_MAXIMUM_CHARACTER_COUNT, message: "The email field can be max #{FIELD_MAXIMUM_CHARACTER_COUNT} characters"
  validate :validate_mail_name_connection
  validates_presence_of :location, message: "Please tell us what your contact is to do with"

  def javascript_enabled
    !!@javascript_enabled
  end

  def link
    @link.present? ? @link : nil
  end

  def save
    if valid?
      if anonymous?
        Feedback.support_api.create_anonymous_long_form_contact(ticket_details)
      else
        Feedback.support.create_named_contact(ticket_details)
      end
    end
  end

  private
  def ticket_details
    details = {
      details: textdetails,
      link: link, # needed for the `support` app
      user_specified_url: link, # needed for the `support-api` app
      user_agent: user_agent,
      referrer: referrer,
      javascript_enabled: javascript_enabled,
      url: url,
      path: url ? URI(url).path : nil, # needed for the `support-api` app
    }
    details[:requester] = { name: name, email: email } unless anonymous?
    details
  end

  def anonymous?
    name.blank? && email.blank?
  end

  def referrer
    referring_url_within_govuk? ? @referrer : nil
  end

  def validate_mail_name_connection
    if name.blank? && email.present?
      @errors.add :name, 'The name field cannot be empty'
    end
    if email.blank? && name.present?
      @errors.add :email, 'The email field cannot be empty'
    end
  end

  def validate_link
    if (location == "specific") && link.blank?
      @errors.add :link, 'The link field cannot be empty'
    end
  end

  def referring_url_within_govuk?
    @referrer && @referrer.starts_with?(Plek.new.website_root)
  end
end
