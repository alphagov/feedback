require 'spec_helper'

describe "Reporting a problem with this content/tool" do

  it "should let the user submit a response to zendesk" do
    visit "/test_forms/report_a_problem"

    fill_in "What you were doing", :with => "I was doing something"
    fill_in "What is wrong with this page", :with => "It didn't work"
    click_on "Send"

    i_should_be_on "/feedback"

    page.should have_content("Thank you for your help.")
    page.should have_link("Return to where you were", :href => "/test_forms/report_a_problem")

    expected_description = <<-EOT
url: http://www.example.com/test_forms/report_a_problem
what_doing: I was doing something
what_wrong: It didn't work
    EOT
    zendesk_should_have_ticket :subject => "/test_forms/report_a_problem", :description => expected_description, :tags => ['report_a_problem']
  end

  it "should handle errors submitting tickets to zendesk" do
    given_zendesk_ticket_creation_fails

    visit "/test_forms/report_a_problem"

    fill_in "What you were doing", :with => "I was doing something"
    fill_in "What is wrong with this page", :with => "It didn't work"
    click_on "Send"

    i_should_be_on "/feedback"

    page.should have_content("Sorry, we're unable to receive your message right now.")
    page.should have_link("support page", :href => "/feedback")
    page.should have_link("Return to where you were", :href => "/test_forms/report_a_problem")
  end
end
