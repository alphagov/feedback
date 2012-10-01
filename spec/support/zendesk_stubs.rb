require 'ticket_client'

module ZendeskStubs
  class MockTicketClient
    def initialize
      @fail = false
      @tickets = []
    end

    attr_accessor :tickets, :fail

    def get_sections
      {"Test Section" =>"test_section"}
    end

    def raise_ticket(params)
      if @fail
        @tickets << params
        raise StandardError
      else
        @tickets << params
        params
      end
    end
  end

  def setup_zendesk_stubs
    @zendesk_client = MockTicketClient.new
    TicketClientConnection.stub(:get_client).and_return(@zendesk_client)
  end

  def zendesk_should_not_have_ticket
    ticket = @zendesk_client.tickets.last
    ticket.should be_nil
  end

  def zendesk_should_have_ticket(params)
    ticket = @zendesk_client.tickets.last
    ticket.should_not be_nil
    params.each do |k,v|
      ticket[k].should == v
    end
  end

  def given_zendesk_ticket_creation_fails
    @zendesk_client.fail = true
  end
end

RSpec.configure do |config|
  config.include ZendeskStubs, :type => :request
  config.before :each, :type => :request do
    setup_zendesk_stubs
  end
end
