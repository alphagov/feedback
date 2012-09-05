require 'spec_helper'

describe "Reporting a problem with this content/tool" do

  it "should let the user submit a response to zendesk" do
    visit "/test_forms/report_a_problem"

    fill_in "What were you doing?", :with => "I was doing something"
    fill_in "What happened?", :with => "It didn't work"
    fill_in "What did you expect to happen?", :with => "It to work"
    click_on "Submit"

    i_should_be_on "/feedback"

    page.should have_content("Thanks for submitting feedback")
    page.should have_link("Return to where you were", :href => "/test_forms/report_a_problem")

    expected_description = <<-EOT
url: http://www.example.com/test_forms/report_a_problem
what_doing: I was doing something
what_happened: It didn't work
what_expected: It to work
    EOT
    zendesk_should_have_ticket :subject => "/test_forms/report_a_problem", :description => expected_description, :tags => ['report_a_problem']
  end

  it "should handle errors submitting tickets to zendesk" do
    given_zendesk_ticket_creation_fails

    visit "/test_forms/report_a_problem"

    fill_in "What were you doing?", :with => "I was doing something"
    fill_in "What happened?", :with => "It didn't work"
    fill_in "What did you expect to happen?", :with => "It to work"
    click_on "Submit"

    i_should_be_on "/feedback"

    page.should have_content("Sorry, there was a problem submitting feedback")
    page.should have_link("Return to where you were", :href => "/test_forms/report_a_problem")
  end
end
