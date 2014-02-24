require 'spec_helper'

describe "Reporting a problem with this content/tool" do
  include GdsApi::TestHelpers::Support

  it "should submit the problem report through the support API" do
    stub_post = stub_support_problem_report_creation(
      url: "http://www.example.com/test_forms/report_a_problem",
      what_doing: "I was doing something",
      what_wrong: "It didn't work",
      user_agent: nil,
      referrer: nil,
      source: nil,
      page_owner: nil,
      javascript_enabled: false
    )

    visit "/test_forms/report_a_problem"

    fill_in "What you were doing", :with => "I was doing something"
    fill_in "What went wrong", :with => "It didn't work"
    click_on "Send"

    i_should_be_on "/contact/govuk/problem_reports"

    page.should have_content("Thank you for your help.")
    page.should have_link("Return to where you were", :href => "/test_forms/report_a_problem")

    assert_requested(stub_post)
  end

  it "should support ajax submission if available", :js => true do
    stub_post = stub_support_problem_report_creation

    visit "/test_forms/report_a_problem"
    page.should have_button('Send')

    fill_in "What you were doing", :with => "I was doing something with javascript"
    fill_in "What went wrong", :with => "It didn't work"
    click_on "Send"

    i_should_be_on "/test_forms/report_a_problem"

    page.should have_content("Thank you for your help.")

    assert_requested(:post, %r{/problem_reports}) do |request|
      response = JSON.parse(request.body)["problem_report"]
      response["what_doing"] == "I was doing something with javascript" &&
        response["what_wrong"] == "It didn't work" &&
        response["javascript_enabled"] == true &&
        response["url"] =~ %r{/test_forms/report_a_problem}
    end
  end

  def valid_params
    {
      :url => "http://www.example.com/test_forms/report_a_problem",
      :what_doing => "I was doing something",
      :what_wrong => "It didn't work"
    }
  end

  it "should include the user_agent if available" do
    stub_support_problem_report_creation

    # Using Rack::Test instead of capybara to allow setting headers.
    post "/contact/govuk/problem_reports", valid_params, {"HTTP_USER_AGENT" => "Shamfari/3.14159 (Fooey)"}

    assert_requested(:post, %r{/problem_reports}) do |request|
      JSON.parse(request.body)["problem_report"]["user_agent"] == "Shamfari/3.14159 (Fooey)"
    end
  end

  it "should still work even if the request doesn't have correct form params" do
    post "/contact/govuk/problem_reports", {}

    response.body.should include("we're unable to send your message")
  end

  it "should handle errors when submitting problem reports" do
    support_isnt_available

    visit "/test_forms/report_a_problem"

    fill_in "What you were doing", :with => "I was doing something"
    fill_in "What went wrong", :with => "It didn't work"
    click_on "Send"

    i_should_be_on "/contact/govuk/problem_reports"

    page.status_code.should == 503
  end

  describe "for html requests" do
    it "should show the error notification if both fields are empty" do
      visit "/test_forms/report_a_problem"

      fill_in "What you were doing", :with => ""
      fill_in "What went wrong", :with => ""
      click_on "Send"

      i_should_be_on "/contact/govuk/problem_reports"

      page.should have_content("Sorry, we're unable to send your message")
    end
  end

  describe "for json requests" do
    it "should show the error notification if both fields are empty", :js => true  do
      visit "/test_forms/report_a_problem"
      page.should have_button('Send')

      fill_in "What you were doing", :with => ""
      fill_in "What went wrong", :with => ""
      click_on "Send"

      i_should_be_on "/test_forms/report_a_problem"
      page.should have_content("Please enter details of what you were doing")
    end
  end
end
