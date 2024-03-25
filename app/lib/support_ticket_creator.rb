require "gds_zendesk/client"
require "gds_zendesk/dummy_client"
require "gds_zendesk/users"

class SupportTicketCreator
  def self.call(...) = new(...).send

  def initialize(hash)
    @zendesk_client = hash[:zendesk_client] ||
      GDSZendesk::Client.new(ZENDESK_CREDENTIALS.merge(logger: Rails.logger)).zendesk_client
    @requester = hash[:requester]
    @body = construct_body(**hash)
  end

  def send
    known_users = @zendesk_client.users.search(query: @requester[:email])
    known_user = known_users.count == 1 ? known_users.first : nil
    if known_user && known_user["suspended"]
      GovukStatsd.increment("report_a_problem.submission_from_suspended_user")
    else
      @zendesk_client.tickets.create!(payload)
    end
  end

  def payload
    {
      subject: "Named contact",
      tags: %w[public_form named_contact],
      priority: "normal",
      comment: { body: @body },
      requester: @requester,
    }
  end

  def construct_body(requester:, details:, link:, javascript_enabled:, referrer: "Unknown", user_agent: "Unknown", **)
    <<~MULTILINE_STRING
      [Requester]
      #{"#{requester[:name]} <#{requester[:email]}>"}

      [Details]
      #{details}

      [Link]
      #{link}

      [Referrer]
      #{referrer}

      [User agent]
      #{user_agent}

      [JavaScript Enabled]
      #{javascript_enabled}
    MULTILINE_STRING
  end
end
