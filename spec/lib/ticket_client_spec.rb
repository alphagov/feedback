require 'spec_helper'

require 'ostruct'
require 'ticket_client'

describe TicketClient do

  describe "creating a client instance" do
    before :each do
      TicketClient.instance_variable_set('@client', nil) # Clear any memoized state
      ZendeskAPI::Client.stub!(:new).and_return(:a_client_instance)
    end
    after :all do
      TicketClient.instance_variable_set('@client', nil) # Clear any memoized state
    end

    it "should create a new instance of the ZendeskAPI Client using details from the config file" do
      YAML.should_receive(:load_file).
        with(Rails.root.join('config', 'zendesk.yml')).
        and_return({"url"=>"https://example.zendesk.com/api/v2", "username"=>"a_user@example.com", "password"=>"super_secret"})

      config_mock = OpenStruct.new
      ZendeskAPI::Client.should_receive(:new).and_yield(config_mock).and_return(:the_client_instance)

      TicketClient.client.should == :the_client_instance
      config_mock.url.should == "https://example.zendesk.com/api/v2"
      config_mock.username.should == "a_user@example.com"
      config_mock.password.should == "super_secret"
    end

    it "should memoize the client instance" do
      TicketClient.client
      ZendeskAPI::Client.should_not_receive(:new)
      TicketClient.client.should == :a_client_instance
    end
  end
end
