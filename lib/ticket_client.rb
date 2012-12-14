require 'zendesk_error'
require 'zendesk_config'

class TicketClient
  SECTION_FIELD = 21649362

  class << self

    def raise_ticket(zendesk)
      tags = zendesk[:tags] << "public_form"
      email = zendesk[:email].presence || fallback_requester_email_address
      unless client.tickets.create(
        :subject => zendesk[:subject],
        :tags => tags,
        :requester => {name: zendesk[:name], email: email},
        :fields => [{id: SECTION_FIELD, value: zendesk[:section]}],
        :description => zendesk[:description])
        raise "Failed to create Zendesk ticket"
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
      @fallback_requester_email_address ||= ZendeskConfig.fallback_requester_email_address
    end

    def build_client
      details = ZendeskConfig.details
      @client = ZendeskAPI::Client.new do |config|
        config.url = details["url"]
        config.username = details["username"]
        config.password = details["password"]
        config.logger = Rails.logger
      end

      @client.insert_callback do |env|
        Rails.logger.info env
        
        status_401 = env[:status].to_s.start_with? "401"
        too_many_login_attempts = env[:body].to_s.start_with? "Too many failed login attempts"
        
        raise ZendeskError, "Authentication Error: #{env.inspect}" if status_401 || too_many_login_attempts
        
        raise ZendeskError, "Error creating ticket: #{env.inspect}" if env[:body]["error"]
      end
      @client
    end
  end
end
