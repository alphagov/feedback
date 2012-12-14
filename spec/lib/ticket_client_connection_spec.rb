require 'spec_helper'

describe TicketClientConnection do

  it "should return a ticket client dummy when in development mode" do
    ZendeskConfig.stub(:details).
      and_return({"development_mode" => true})
    client = TicketClientConnection.get_client
    client.should == TicketClientDummy
  end

  it "should return a ticket client when in non development mode" do
    ZendeskConfig.stub(:details).
      and_return({"development_mode" => false})
    client = TicketClientConnection.get_client
    client.should == TicketClient
  end
end
