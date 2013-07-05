require 'spec_helper'

describe ReportAProblemTicket do
  def ticket(params={})
    ReportAProblemTicket.new(params)
  end

  it "should add a tag identifying the whitelisted source" do
    ticket.tags.should eq(['report_a_problem'])
    ticket(source: 'inside_government').tags.should eq(['report_a_problem', 'inside_government'])
    ticket(source: 'mainstream').tags.should eq(['report_a_problem', 'mainstream'])
    ticket(source: 'page_not_found').tags.should eq(['report_a_problem', 'page_not_found'])
    ticket(source: 'random').tags.should eq(['report_a_problem'])
  end

  it "should add a tag identifying the page owner" do
    ticket(page_owner: 'hmrc').tags.should eq(['report_a_problem', 'page_owner/hmrc'])
    ticket(page_owner: 'number_10').tags.should eq(['report_a_problem', 'page_owner/number_10'])
    ticket(page_owner: 'home_office', source: 'inside_government').tags.should eq(['report_a_problem', 'inside_government', 'page_owner/home_office'])
  end

  it "ignores the page owner if it contains any non-alphanumeric characters, other than underscore" do
    ticket(page_owner: 'spaces not allowed').tags.should eq(['report_a_problem'])
    ticket(page_owner: '<hax>').tags.should eq(['report_a_problem'])
    ticket(page_owner: 'S&P').tags.should eq(['report_a_problem'])
  end
end
