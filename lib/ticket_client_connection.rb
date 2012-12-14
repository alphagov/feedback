require 'zendesk_config'

class TicketClientConnection
  class << self
    def get_client
      if ZendeskConfig.in_development_mode?
        TicketClientDummy
      else
        TicketClient
      end
    end
  end
end
