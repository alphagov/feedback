require 'ticket_client'

module ZendeskStubs
  class MockTicketClient
    def initialize
      @tickets = []
    end

    attr_accessor :tickets

    def get_departments
      {"Test Department" =>"test_department"}
    end

    def raise_ticket(params)
      @tickets << params
      params
    end
  end

  def setup_zendesk_stubs
    @zendesk_client = MockTicketClient.new
    TicketClientConnection.stub(:get_client).and_return(@zendesk_client)
  end

  def zendesk_should_have_ticket(params)
    ticket = @zendesk_client.tickets.last
    ticket.should_not be_nil
    params.each do |k,v|
      ticket[k].should == v
    end
  end

  def given_zendesk_ticket_creation_fails
    @zendesk_tickets.stub(:create).and_return(nil)
  end
end

RSpec.configure do |config|
  config.include ZendeskStubs, :type => :request
  config.before :each, :type => :request do
    setup_zendesk_stubs
  end
end
