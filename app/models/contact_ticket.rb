class ContactTicket < Ticket

  attr_accessor :query, :location, :link, :textdetails,
                :section, :name, :email, :user_agent,
                :javascript_enabled

  validate :validate_link
  validates_length_of :link, :maximum => 1200, :message => "The page field can be max 1200 characters"
  validates_presence_of :textdetails, :message => "The message field cannot be empty"
  validates_length_of :textdetails, :maximum => 1200, :message => "The message field can be max 1200 characters"
  validates_length_of :name, :maximum => 1200, :message => "The name field can be max 1200 characters"
  validates_format_of :email, :with => /\A\z|\A[\w\d]+[^@]*@[\w\d]+[^@]*\.[\w\d]+[^@]*\z/, :message => "The email address must be valid"
  validates_length_of :email, :maximum => 1200, :message => "The email field can be max 1200 characters"
  validate :validate_mail_name_connection

  def javascript_enabled
    @javascript_enabled || false
  end

  def user_agent
    @user_agent || "unknown"
  end

  private

  REASON_HASH = {
    "cant-find" => {:subject => "I can't find", :tag => "i_cant_find"},
    "ask-question" => {:subject => "Ask a question", :tag => "ask_question"},
    "report-problem" => {:subject => "Report a problem", :tag => "report_a_problem_public"},
    "make-suggestion" => {:subject => "General feedback", :tag => "general_feedback"}
  }

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
    description += "\n[JavaScript Enabled]\n#{javascript_enabled}"

    description
  end

  def create_ticket
    ticket = {}
    if REASON_HASH[query]
      description = contact_ticket_description
      subject = REASON_HASH[query][:subject]
      tag = REASON_HASH[query][:tag]
      ticket = {
        :subject => subject,
        :tags => [tag],
        :name => name,
        :email => email,
        :section => section,
        :description => description
      }
    end
    ticket
  end

  def validate_mail_name_connection
    if name.blank? and not email.blank?
      @errors.add :name, 'The name field cannot be empty'
    end
    if email.blank? and not name.blank?
      @errors.add :email, 'The email field cannot be empty'
    end
  end

  def validate_link
    if (location == "specific") and link.blank?
      @errors.add :link, 'The link field cannot be empty'
    end
  end
end
