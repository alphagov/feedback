# encoding: UTF-8
require 'spec_helper'

describe ReportAProblemTicket do
  def ticket(params={})
    ReportAProblemTicket.new(params)
  end

  it "should validate the presence of 'what_wrong'" do
    ticket(what_wrong: '').should have(1).error_on(:what_wrong)
  end

  it "should validate the presence of 'what_doing'" do
    ticket(what_doing: '').should have(1).error_on(:what_doing)
  end

  it "should filter 'javascript_enabled'" do
    ticket(javascript_enabled: 'true').javascript_enabled.should be_true

    ticket(javascript_enabled: 'false').javascript_enabled.should be_false
    ticket(javascript_enabled: 'xxx').javascript_enabled.should be_false
    ticket(javascript_enabled: '').javascript_enabled.should be_false
  end

  it "should filter 'page_owner'" do
    ticket(page_owner: 'abc').page_owner.should eq('abc')
    ticket(page_owner: 'number_10').page_owner.should eq('number_10')

    ticket(page_owner: nil).page_owner.should be_nil
    ticket(page_owner: '').page_owner.should be_nil
    ticket(page_owner: 'spaces not allowed').page_owner.should be_nil
    ticket(page_owner: '<hax>').page_owner.should be_nil
    ticket(page_owner: 'S&P').page_owner.should be_nil
  end

  it "should filter 'source'" do
    ticket(source: 'mainstream').source.should eq('mainstream')
    ticket(source: 'page_not_found').source.should eq('page_not_found')
    ticket(source: 'inside_government').source.should eq('inside_government')

    ticket(source: 'xxx').source.should be_nil
  end

  it "should filter 'referrer' to either nil or a valid URL" do
    ticket(referrer: "https://www.gov.uk").referrer.should eq('https://www.gov.uk')
    ticket(referrer: "http://bla.example.org:9292/méh/fào?bar").referrer.should be_nil
    ticket(referrer: nil).referrer.should be_nil
  end

  it "should treat a 'unknown' referrer as nil" do
    expect(ticket(referrer: "unknown").referrer).to be_nil
  end
end
