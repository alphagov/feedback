require 'zendesk_error'

class TicketClient
  SECTION_FIELD = 21649362

  class << self

    def raise_ticket(zendesk)
      tags = zendesk[:tags] << "public_form"
      unless client.tickets.create(
        :subject => zendesk[:subject],
        :tags => tags,
        :requester => {name: zendesk[:name], email: zendesk[:email]},
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

    def build_client
      details = YAML.load_file(Rails.root.join('config', 'zendesk.yml'))
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
