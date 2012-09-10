class TicketClient

  class << self
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
      @client ||= build_client
    end

    private

    def build_client
      details = YAML.load_file(Rails.root.join('config', 'zendesk.yml'))
      if details["development_mode"]
        DummyClient.new
      else
        ZendeskAPI::Client.new do |config|
          config.url = details["url"]
          config.username = details["username"]
          config.password = details["password"]
          config.logger = Rails.logger
        end
      end
    end

    def path_for_url(url)
      uri = URI.parse(url)
      uri.path
    rescue URI::InvalidURIError
      "Unknown page"
    end
  end # << self

  class DummyClient
    class Tickets
      def self.create(attrs)
        if attrs[:description] =~ /break_zendesk/
          Rails.logger.info "Simulating Zendesk ticket creation fail for: #{attrs.inspect}"
          nil
        else
          Rails.logger.info "Zendesk ticket created: #{attrs.inspect}"
          attrs
        end
      end
    end

    def tickets
      Tickets
    end
  end
end
