require 'spec_helper'

describe "Reporting a problem with this content/tool" do

  it "should let the user submit a response to zendesk" do
    visit "/test_forms/report_a_problem"

    fill_in "What you were doing", :with => "I was doing something"
    fill_in "What went wrong", :with => "It didn't work"
    click_on "Send"

    i_should_be_on "/feedback"

    page.should have_content("Thank you for your help.")
    page.should have_link("Return to where you were", :href => "/test_forms/report_a_problem")

    expected_description = <<-EOT
url: http://www.example.com/test_forms/report_a_problem
what_doing: I was doing something
what_wrong: It didn't work
user_agent: unknown
referrer: unknown
javascript_enabled: false
    EOT
    zendesk_should_have_ticket :subject => "/test_forms/report_a_problem", :description => expected_description, :tags => ['report_a_problem']
  end

  it "should support ajax submission if available", :js => true do
    visit "/test_forms/report_a_problem"

    fill_in "What you were doing", :with => "I was doing something with javascript"
    fill_in "What went wrong", :with => "It didn't work"
    click_on "Send"

    i_should_be_on "/test_forms/report_a_problem"

    page.should have_content("Thank you for your help.")

    ticket = get_last_zendesk_ticket_details
    ticket.should_not be_nil

    ticket_fields = ticket[:description].lines.each_with_object(Hash.new) do |line, fields|
      next if line =~ /\A\s+\z/
      key, value = line.split(': ', 2)
      fields[key.to_sym] = value.chomp
    end

    ticket_fields[:what_doing].should == "I was doing something with javascript"
    ticket_fields[:what_wrong].should == "It didn't work"
    URI.parse(ticket_fields[:url]).path.should == "/test_forms/report_a_problem"
    ticket_fields[:user_agent].should =~ /phantomjs/i
    ticket_fields[:javascript_enabled].should == "true"
  end

  it "should include the user_agent if available" do
    # Using Rack::Test instead of capybara to allow setting the user agent.
    post "/feedback", {
      :url => "http://www.example.com/test_forms/report_a_problem",
      :what_doing => "I was doing something",
      :what_wrong => "It didn't work"
    }, {"HTTP_USER_AGENT" => "Shamfari/3.14159 (Fooey)"}

    expected_description = <<-EOT
url: http://www.example.com/test_forms/report_a_problem
what_doing: I was doing something
what_wrong: It didn't work
user_agent: Shamfari/3.14159 (Fooey)
referrer: unknown
javascript_enabled: false
    EOT
    zendesk_should_have_ticket :subject => "/test_forms/report_a_problem", :description => expected_description, :tags => ['report_a_problem']
  end

  it "should handle errors submitting tickets to zendesk" do
    given_zendesk_ticket_creation_fails

    visit "/test_forms/report_a_problem"

    fill_in "What you were doing", :with => "I was doing something"
    fill_in "What went wrong", :with => "It didn't work"
    click_on "Send"

    i_should_be_on "/feedback"

    page.should have_content("Sorry, we're unable to receive your message right now.")
    page.should have_link("support page", :href => "/feedback")
    page.should have_link("Return to where you were", :href => "/test_forms/report_a_problem")
  end

  describe "for html requests" do
    it "should show the error notification if both fields are empty" do
      visit "/test_forms/report_a_problem"

      fill_in "What you were doing", :with => ""
      fill_in "What went wrong", :with => ""
      click_on "Send"

      i_should_be_on "/feedback"

      page.should have_content("Sorry, we're unable to send your message")
    end
  end

  describe "for json requests" do
    it "should show the error notification if both fields are empty", :js => true  do
      visit "/test_forms/report_a_problem"

      fill_in "What you were doing", :with => ""
      fill_in "What went wrong", :with => ""
      click_on "Send"

      i_should_be_on "/test_forms/report_a_problem"
      page.should have_content("Please enter details of what you were doing")
    end
  end
end
