require 'spec_helper'

require 'ostruct'
require 'ticket_client'

describe TicketClient do

  describe "report a problem" do
    before :each do
      @tickets = double("Tickets", :create => nil)
      TicketClient.stub(:client).and_return(double("Zendesk Client", :tickets => @tickets))
    end

    it "should create a ticket in zendesk with the correct fields" do
      expected_description = <<-EOT
url: http://www.example.com/somewhere
what_doing: Nothing
what_wrong: Something
      EOT
      @tickets.should_receive(:create).with(:subject => "/somewhere", :tags => ['report_a_problem'], :description => expected_description)

      TicketClient.report_a_problem(
        :url => "http://www.example.com/somewhere",
        :what_doing => "Nothing",
        :what_wrong => "Something"
      )
    end

    describe "handling invalid/missing url's" do
      it "should set the subject to unknown page for a missing url" do
        @tickets.should_receive(:create).with(hash_including(:subject => "Unknown page"))

        TicketClient.report_a_problem(:url => nil)
      end

      it "should set the subject to unknown page for an invalid url" do
        @tickets.should_receive(:create).with(hash_including(:subject => "Unknown page"))

        TicketClient.report_a_problem(:url => "Not a URL")
      end
    end

    it "should return true if the ticket was created" do
      @tickets.stub(:create).and_return(:a_ticket)

      TicketClient.report_a_problem(
        :url => "http://www.example.com/somewhere",
        :what_doing => "Nothing",
        :what_wrong => "Something"
      ).should == true
    end

    it "should return false if there was an error" do
      @tickets.stub(:create).and_return(nil) # ZendeskAPI swallows all errors, and just returns nil...

      TicketClient.report_a_problem(
        :url => "http://www.example.com/somewhere",
        :what_doing => "Nothing",
        :what_wrong => "Something"
      ).should == false
    end
  end

  describe "creating a client instance" do
    before :each do
      TicketClient.instance_variable_set('@client', nil) # Clear any memoized state
      YAML.stub(:load_file).
        with(Rails.root.join('config', 'zendesk.yml')).
        and_return({"url"=>"https://example.zendesk.com/api/v2", "username"=>"a_user@example.com", "password"=>"super_secret"})
      ZendeskAPI::Client.stub(:new).and_return(:a_client_instance)
      TicketClient::DummyClient.stub(:new).and_return(:a_dummy_client)
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

    it "should set the client logger to the Rails logger" do
      config_mock = OpenStruct.new
      ZendeskAPI::Client.should_receive(:new).and_yield(config_mock)

      TicketClient.client
      config_mock.logger.should == Rails.logger
    end

    it "should memoize the client instance" do
      TicketClient.client
      ZendeskAPI::Client.should_not_receive(:new)
      TicketClient.client.should == :a_client_instance
    end

    context "when in development mode" do
      before :each do
        YAML.stub(:load_file).
          with(Rails.root.join('config', 'zendesk.yml')).
          and_return({"development_mode"=>true})
      end

      it "should create and return a new instance of the dummy client" do
        TicketClient::DummyClient.should_receive(:new).and_return(:dummy_client)
        TicketClient.client.should == :dummy_client
      end

      it "should memoize the dummy client instance" do
        TicketClient.client
        TicketClient::DummyClient.should_not_receive(:new)
        TicketClient.client.should == :a_dummy_client
      end
    end
  end
end

describe TicketClient::DummyClient do
  before :each do
    @client = TicketClient::DummyClient.new
  end

  it "should log ticket creation to the Rails log" do
    details = {:subject => "/somewhere", :tags => ['report_a_problem'], :description => "some_description_stuff\nsome_more_stuff"}

    Rails.logger.should_receive(:info).
      with("Zendesk ticket created: {:subject=>\"/somewhere\", :tags=>[\"report_a_problem\"], :description=>\"some_description_stuff\\nsome_more_stuff\"}")

    @client.tickets.create(details).should be_true
  end
end
