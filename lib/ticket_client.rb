require 'zendesk_error'
require 'zendesk_config'

class TicketClient
  SECTION_FIELD = 21649362

  class << self

    def raise_ticket(zendesk)
      tags = zendesk[:tags] << "public_form"
      email = zendesk[:email].presence || fallback_requester_email_address
      ticket_details = {
        subject: zendesk[:subject],
        tags: tags,
        requester: {name: zendesk[:name], email: email},
        fields: [{id: SECTION_FIELD, value: zendesk[:section]}],
        description: zendesk[:description]
      }
      unless client.tickets.create!(ticket_details)
        raise ZendeskDidntCreateTicketError, "Failed to create Zendesk ticket: #{ticket_details.inspect}"
      end
    end

    def get_sections
      sections_hash = {}
      unless client.nil?
        section_field = client.ticket_fields.find(:id => SECTION_FIELD)
        unless section_field.nil?
          section_field.custom_field_options.each do |tf|
            sections_hash[tf.name] = tf.value
          end
        end
      end
      sections_hash
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
