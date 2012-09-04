require 'spec_helper'

describe "Reporting a problem with this content/tool" do
  it "should let the user submit a response to zendesk" do
    visit "/test_forms/report_a_problem"

    fill_in "Comment", :with => "Sample comment with a problem"
    click_on "Submit"

    i_should_be_on "/feedback"

    page.should have_content("Thanks for submitting feedback")
  end
end
