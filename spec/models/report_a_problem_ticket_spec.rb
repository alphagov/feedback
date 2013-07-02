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

  it "should add a tag identifying the page owner" do
    ticket(page_owner: 'hmrc').tags.should eq(['report_a_problem', 'page_owner/hmrc'])
    ticket(page_owner: 'number_10').tags.should eq(['report_a_problem', 'page_owner/number_10'])
    ticket(page_owner: 'home_office', source: 'government').tags.should eq(['report_a_problem', 'government', 'page_owner/home_office'])
  end

  it "ignores the page owner if it contains any non-alphanumeric characters, other than underscore" do
    ticket(page_owner: 'spaces not allowed').tags.should eq(['report_a_problem'])
    ticket(page_owner: '<hax>').tags.should eq(['report_a_problem'])
    ticket(page_owner: 'S&P').tags.should eq(['report_a_problem'])
  end
end
