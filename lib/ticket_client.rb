class TicketClient

  def self.client
    @client ||= ZendeskAPI::Client.new do |config|
      details = YAML.load_file(Rails.root.join('config', 'zendesk.yml'))

      config.url = details["url"]
      config.username = details["username"]
      config.password = details["password"]
    end
  end
end
