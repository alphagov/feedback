require 'ticket_client'

module ZendeskStubs
  class MockTicketCollection
    def initialize
      @tickets = []
    end

    attr_accessor :tickets

    def create(params)
      @tickets << params
      params
    end
  end

  def setup_zendesk_stubs
    @zendesk_tickets = MockTicketCollection.new
    TicketClient.stub(:client).and_return( double("ZendeskClient", :tickets => @zendesk_tickets) )
  end

  def zendesk_should_have_ticket(params)
    ticket = @zendesk_tickets.tickets.last
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
