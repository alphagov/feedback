require 'zendesk_didnt_create_ticket_error'
require 'zendesk_config'

class TicketClient
  class << self
    def raise_ticket(zendesk)
      tags = zendesk[:tags] << "public_form"
      email = zendesk[:email].presence || fallback_requester_email_address
      ticket_details = {
        subject: zendesk[:subject],
        tags: tags,
        requester: {name: zendesk[:name], email: email},
        description: zendesk[:description]
      }
      unless client.tickets.create!(ticket_details)
        raise ZendeskDidntCreateTicketError, "Failed to create Zendesk ticket: #{ticket_details.inspect}"
      end
    end

    def client
      @client ||= build_client
    end

    private

    def fallback_requester_email_address
      ZendeskConfig.fallback_requester_email_address
    end

    def build_client
      details = ZendeskConfig.details
      ZendeskAPI::Client.new do |config|
        config.url = details["url"]
        config.username = details["username"]
        config.password = details["password"]
        config.logger = Rails.logger
      end
    end
  end
end
