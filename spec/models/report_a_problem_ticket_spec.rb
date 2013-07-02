require 'spec_helper'

describe ReportAProblemTicket do
  def ticket(params={})
    ReportAProblemTicket.new(params)
  end

  it "should add a tag identifying the whitelisted source" do
    ticket.tags.should eq(['report_a_problem'])
    ticket(source: 'government').tags.should eq(['report_a_problem', 'government'])
    ticket(source: 'citizen').tags.should eq(['report_a_problem', 'citizen'])
    ticket(source: 'specialist').tags.should eq(['report_a_problem', 'specialist'])
    ticket(source: 'random').tags.should eq(['report_a_problem'])
  end
end
