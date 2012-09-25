class TicketClient
  DEPARTMENT_FIELD = 21649362

  class << self

    def raise_ticket(zendesk)
      tags = zendesk[:tags] << "public_form"
      result = client.tickets.create(
        :subject => zendesk[:subject],
        :tags => tags,
        :requester => {name: zendesk[:name], email: zendesk[:email]},
        :fields => [{id: DEPARTMENT_FIELD, value: zendesk[:department]}],
        :description => zendesk[:description]
      )
      !! result
    end

    def get_departments
      departments_hash = {}
      unless client.nil?
        department_field = client.ticket_fields.find(:id => DEPARTMENT_FIELD)
        unless department_field.nil?
          department_field.custom_field_options.each do |tf| 
            departments_hash[tf.name] = tf.value
          end
        end
      end
      departments_hash
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
    end
  end
end
