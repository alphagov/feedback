require "gds_zendesk/client"
require "gds_zendesk/dummy_client"
require "gds_zendesk/users"

class SupportTicketCreator
  def self.call(...) = new(...).send

  def initialize(hash)
    @requester = hash[:requester]
    @body = construct_body(**hash)
  end

  def send
    zendesk_client.users.search(query: @requester[:email])
    zendesk_client.tickets.create!(payload)
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

private

  def zendesk_client
    client = if Rails.env.development?
               GDSZendesk::DummyClient.new(logger: Rails.logger)
             else
               GDSZendesk::Client.new(ZENDESK_CREDENTIALS.merge(logger: Rails.logger))
             end
    client.zendesk_client
  end
end
