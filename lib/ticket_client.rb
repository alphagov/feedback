class TicketClient

  class << self
    def report_a_problem(params)
      description = <<-EOT
url: #{params[:url]}
what_doing: #{params[:what_doing]}
what_happened: #{params[:what_happened]}
what_expected: #{params[:what_expected]}
      EOT
      result = client.tickets.create(
        :subject => path_for_url(params[:url]),
        :description => description,
        :tags => ['report_a_problem']
      )
      !! result
    end

    def client
      @client ||= ZendeskAPI::Client.new do |config|
        details = YAML.load_file(Rails.root.join('config', 'zendesk.yml'))

        config.url = details["url"]
        config.username = details["username"]
        config.password = details["password"]

        config.logger = Rails.logger
      end
    end

    private

    def path_for_url(url)
      uri = URI.parse(url)
      uri.path
    rescue URI::InvalidURIError
      "Unknown page"
    end
  end # << self
end
