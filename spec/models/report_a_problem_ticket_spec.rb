require "rails_helper"

RSpec.describe ReportAProblemTicket, type: :model do
  let(:support_api) { Rails.application.config.support_api }

  def ticket(params = {})
    ReportAProblemTicket.new(params)
  end

  it "should create a ticket" do
    allow(support_api).to receive(:create_problem_report).and_return(true)

    expect(ticket(
      what_wrong: "The page is broken",
      what_doing: "Submitting a form",
    ).save).to be_truthy

    expect(support_api).to have_received(:create_problem_report).with(
      javascript_enabled: false,
      page_owner: nil,
      path: nil,
      referrer: nil,
      source: nil,
      user_agent: nil,
      what_wrong: "The page is broken",
      what_doing: "Submitting a form",
    )
  end

  it "should validate the presence of 'what_wrong'" do
    expect(ticket(what_wrong: "").errors[:what_wrong].size).to eq(1)
  end

  it "should validate the presence of 'what_doing'" do
    expect(ticket(what_doing: "").errors[:what_doing].size).to eq(1)
  end

  it "should filter 'javascript_enabled'" do
    expect(ticket(javascript_enabled: "true").javascript_enabled).to be_truthy

    expect(ticket(javascript_enabled: "false").javascript_enabled).to be_falsey
    expect(ticket(javascript_enabled: "xxx").javascript_enabled).to be_falsey
    expect(ticket(javascript_enabled: "").javascript_enabled).to be_falsey
  end

  it "should filter 'page_owner'" do
    expect(ticket(page_owner: "abc").page_owner).to eq("abc")
    expect(ticket(page_owner: "number_10").page_owner).to eq("number_10")

    expect(ticket(page_owner: nil).page_owner).to be_nil
    expect(ticket(page_owner: "").page_owner).to be_nil
    expect(ticket(page_owner: "spaces not allowed").page_owner).to be_nil
    expect(ticket(page_owner: "<hax>").page_owner).to be_nil
    expect(ticket(page_owner: "S&P").page_owner).to be_nil
  end

  it "should filter 'source'" do
    expect(ticket(source: "mainstream").source).to eq("mainstream")
    expect(ticket(source: "page_not_found").source).to eq("page_not_found")
    expect(ticket(source: "inside_government").source).to eq("inside_government")

    expect(ticket(source: "xxx").source).to be_nil
  end

  context "spam detection" do
    it "should mark single word submissions as spam" do
      expect(ticket(what_doing: "oneword", what_wrong: "")).to be_spam
      expect(ticket(what_doing: "", what_wrong: "oneword")).to be_spam
      expect(ticket(what_doing: "oneword", what_wrong: "oneword")).to be_spam
    end

    it "should mark Web Cruiser scanning as spam" do
      expect(ticket(what_doing: "WCRTESTINP scanning")).to be_spam
      expect(ticket(what_wrong: "WCRTESTINP scanning")).to be_spam
    end

    it "should mark duplicate values in 'what_doing' and 'what_wrong' fields as spam" do
      expect(ticket(what_doing: "Lorem ipsum dolor sit amet", what_wrong: "Lorem ipsum dolor sit amet")).to be_spam
    end

    it "should mark submissions sent in four seconds or less as spam" do
      expect(ticket(what_doing: "Lorem ipsum 1", what_wrong: "Lorem ipsum dolor sit amet", javascript_enabled: "true", timer: "0")).to be_spam
      expect(ticket(what_doing: "Lorem ipsum 2", what_wrong: "Lorem ipsum dolor sit", javascript_enabled: "true", timer: "4")).to be_spam
    end

    it "should allow genuine submissions" do
      expect(ticket(what_doing: "browsing", what_wrong: "it broke")).to_not be_spam
      expect(ticket(what_doing: "browsing", what_wrong: "it broke", javascript_enabled: "true", timer: "5")).to_not be_spam
      expect(ticket(what_doing: "browsing", what_wrong: "it broke", javascript_enabled: "false", timer: "0")).to_not be_spam
    end
  end
end
