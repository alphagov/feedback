# encoding: UTF-8
require 'spec_helper'

describe Ticket do
  it { should allow_value("https://www.gov.uk/done/whatever").for(:url) }
  it { should_not be_spam}

  context "a bot has populated the val field" do
    let(:subject) { Ticket.new(val: "xxxxx") }
    it { should be_spam}
    it { should_not be_valid }
  end

  it "should validate the length of URLs" do
    Ticket.new(url: 'https://www.gov.uk/' + ("a" * 2048)).should have(1).error_on(:url)
  end

  it "should filter 'url' to either nil or a valid URL" do
    Ticket.new(url: "https://www.gov.uk").url.should eq('https://www.gov.uk')
    Ticket.new(url: "http://bla.example.org:9292/méh/fào?bar").url.should be_nil
    Ticket.new(url: nil).url.should be_nil
  end

  it "should add the website root to relative URLs" do
    Ticket.new(url: '/relative/url').url.should eq("#{Plek.new.website_root}/relative/url")
  end

  it "should filter 'referrer' to either nil or a valid URL" do
    expect(Ticket.new(referrer: "https://www.gov.uk").referrer).to eq('https://www.gov.uk')
    expect(Ticket.new(referrer: "http://bla.example.org:9292/méh/fào?bar").referrer).to be_nil
    expect(Ticket.new(referrer: nil).referrer). to be_nil
  end

  it "should treat a 'unknown' referrer as nil" do
    expect(Ticket.new(referrer: "unknown").referrer).to be_nil
  end
end
