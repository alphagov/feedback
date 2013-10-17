require 'gds_api/support'

class ContactTicket < Ticket
  attr_accessor :location, :link, :textdetails,
                :name, :email,
                :javascript_enabled, :referrer

  validate :validate_link
  validates_length_of :link, :maximum => FIELD_MAXIMUM_CHARACTER_COUNT, :message => "The page field can be max #{FIELD_MAXIMUM_CHARACTER_COUNT} characters"
  validates_presence_of :textdetails, :message => "The message field cannot be empty"
  validates_length_of :textdetails, :maximum => FIELD_MAXIMUM_CHARACTER_COUNT, :message => "The message field can be max #{FIELD_MAXIMUM_CHARACTER_COUNT} characters"
  validates_length_of :name, :maximum => FIELD_MAXIMUM_CHARACTER_COUNT, :message => "The name field can be max #{FIELD_MAXIMUM_CHARACTER_COUNT} characters"
  validates :email, email: { message: "The email address must be valid" }, allow_blank: true
  validates_length_of :email, :maximum => FIELD_MAXIMUM_CHARACTER_COUNT, :message => "The email field can be max #{FIELD_MAXIMUM_CHARACTER_COUNT} characters"
  validate :invalidate_trailing_dot_in_email
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
      support_api = GdsApi::Support.new(SUPPORT_API[:url], bearer_token: SUPPORT_API[:bearer_token])
      if anonymous?
        support_api.create_anonymous_long_form_contact(ticket_details, headers: { "X-Varnish" => varnish_id })
      else
        support_api.create_named_contact(ticket_details, headers: { "X-Varnish" => varnish_id })
      end
    end
  end

  private
  def ticket_details
    details = {
      details: textdetails,
      link: link,
      user_agent: user_agent,
      referrer: referrer,
      javascript_enabled: javascript_enabled,
    }
    details[:requester] = { name: name, email: email } unless anonymous?
    details
  end

  def anonymous?
    name.blank? and email.blank?
  end

  def referrer
    referring_url_within_govuk? ? @referrer : nil
  end

  def validate_mail_name_connection
    if name.blank? and not email.blank?
      @errors.add :name, 'The name field cannot be empty'
    end
    if email.blank? and not name.blank?
      @errors.add :email, 'The email field cannot be empty'
    end
  end

  def invalidate_trailing_dot_in_email
    if not email.nil? and email.end_with?(".")
      @errors.add :email, "The email address must not have a trailing full stop"
    end
  end

  def validate_link
    if (location == "specific") and link.blank?
      @errors.add :link, 'The link field cannot be empty'
    end
  end

  def referring_url_within_govuk?
    @referrer and @referrer.starts_with?(ENV['GOVUK_WEBSITE_ROOT'])
  end
end
