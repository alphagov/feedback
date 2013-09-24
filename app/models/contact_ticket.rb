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
    !! @javascript_enabled
  end

  def user_agent
    @user_agent || "unknown"
  end

  def subject
    anonymous? ? "Anonymous contact" : "Named contact"
  end

  private
  def contact_ticket_description
    description = "[Location]\n" + location
    if (location == "specific") and (not link.blank?)
      description += "\n[Link]\n" + link
    end
    unless name.blank?
      description += "\n[Name]\n" + name
    end

    unless textdetails.blank?
      description += "\n[Details]\n" + textdetails
    end

    description += "\n[User Agent]\n#{user_agent}"
    description += "\n[Referrer]\n#{referrer}" if referring_url_within_govuk?
    description += "\n[JavaScript Enabled]\n#{javascript_enabled}"

    description
  end

  def create_ticket
    {
      subject: subject,
      tags: [],
      name: name,
      email: email,
      description: contact_ticket_description
    }
  end

  def anonymous?
    name.blank? and email.blank?
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
