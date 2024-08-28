require "uri"

class SupportTicketCreator
  def self.call(...) = new(...).send

  def initialize(hash)
    @requester = hash[:requester]
    @subject = construct_subject(hash[:link])
    @body = construct_body(**hash)
  end

  def send
    GdsApi.support_api.raise_support_ticket(payload)
  end

  def payload
    {
      subject: @subject,
      tags: %w[public_form named_contact],
      priority: "normal",
      description: @body,
      requester: @requester,
    }
  end

  def construct_subject(link)
    path = nil
    begin
      uri = URI.parse(link)
      path = uri.path if uri.host == "www.gov.uk"
    rescue URI::InvalidURIError
      # If invalid URI provided by user, we'll just go with a general subject line
    end
    "Named contact#{path.present? ? " about #{path}" : ''}"
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
