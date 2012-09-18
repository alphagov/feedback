class TicketClient
  @@DEPARTMENT_FIELD = 21494928

  class << self

    def raise_ticket(zendesk)
      tags = zendesk[:tags] << "public_form"
      result = client.tickets.create(
        :subject => zendesk[:subject],
        :tags => tags,
        :requester => {name: zendesk[:name], email: zendesk[:email]},
        :fields => [{id: @@DEPARTMENT_FIELD, value: zendesk[:department]}],
        :description => zendesk[:description]
      )
      !! result
    end

    def get_departments
      departments_hash = {}
      department_field = client.ticket_fields.find(:id => @@DEPARTMENT_FIELD)
      department_field.custom_field_options.each do |tf| 
        departments_hash[tf.name] = tf.value
      end
      departments_hash
    end

    def report_a_problem(params)
      description = <<-EOT
url: #{params[:url]}
what_doing: #{params[:what_doing]}
what_wrong: #{params[:what_wrong]}
EOT
result = client.tickets.create(
  :subject => path_for_url(params[:url]),
  :description => description,
  :tags => ['report_a_problem']
)
!! result
    end

    def client 
      @@client ||= build_client
    end

    private

    def build_client
      details = YAML.load_file(Rails.root.join('config', 'zendesk.yml'))
      @@client = ZendeskAPI::Client.new do |config|
        config.url = details["url"]
        config.username = details["username"]
        config.password = details["password"]
        config.logger = Rails.logger
      end
    end

    def path_for_url(url)
      uri = URI.parse(url)
      uri.path
    rescue URI::InvalidURIError
      "Unknown page"
    end

  end # << self

end
