require 'spec_helper'

require 'ostruct'

describe TicketClientDummy do

  before :each do
    YAML.stub(:load_file).
      with(Rails.root.join('config', 'zendesk.yml')).
      and_return({'development_mode' => true})
    @client = TicketClientConnection.get_client
  end

  it 'should simulate raising a ticket' do
    details = {
      :subject => 'test_subject',
      :tags => ['test_tag'],
      :description => 'test_description'
    }

    Rails.logger.should_receive(:info).
      with("Zendesk ticket created: #{details}")
    @client.raise_ticket(details).should be_true
  end

  it 'should simulate failing raising a ticket' do
    details = {
      :subject => 'test_subject',
      :tags => ['test_tag'],
      :description => 'break_zendesk'
    }
    Rails.logger.should_receive(:info).
      with("Zendesk ticket creation fail for: #{details}")
    @client.raise_ticket(details).should == nil
  end

  it 'should simulate returning available departments' do
    Rails.logger.should_receive(:info).
      with('Zendesk get departments')
    @client.get_departments.should_not be_empty
  end
end
