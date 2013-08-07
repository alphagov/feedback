require 'spec_helper'
require 'support/support_app_stubs'

class DummyZendeskTicketsStub
  attr_accessor :raised_ticket

  def create!(ticket_info)
    @raised_ticket = ticket_info
  end
end

describe TicketClient do
  include SupportAppStubs

  it "should specify a fallback email if none is provided" do
    ZendeskConfig.stub(:fallback_requester_email_address).and_return("a@b.com")

    stub_tickets = DummyZendeskTicketsStub.new
    stub_client = double(ZendeskAPI::Client, insert_callback: nil, tickets: stub_tickets)
    ZendeskAPI::Client.stub(:new).and_return(stub_client)

    TicketClient.raise_ticket(tags: [], email: "")
    stub_tickets.raised_ticket[:requester][:email].should eq("a@b.com")
  end

  it "should raise a RuntimeError if it gets anything apart from 201 from the support app" do
    stub_request(:post,  /.*?\/foi_requests/).to_return(status: 200)

    lambda { TicketClient.raise_foi_request({}) }.should raise_error(RuntimeError)
  end
end