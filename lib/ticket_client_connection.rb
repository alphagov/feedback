require 'ticket_client'
require 'ticket_client_dummy'

class TicketClientConnection
  def self.get_client
    details = YAML.load_file(Rails.root.join('config', 'zendesk.yml'))
    if details["development_mode"]
      TicketClientDummy
    else
      TicketClient
    end
  end
end
