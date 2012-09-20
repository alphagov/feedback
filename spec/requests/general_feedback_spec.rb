require 'spec_helper'

describe "General Feedback" do

  it "should let the user submit general feedback" do
    visit "/feedback/general-feedback"

    fill_in "Name", :with => "test name"
    fill_in "Email", :with => "a@a.com"
    fill_in "Verify email", :with => "a@a.com"
    fill_in "How can we improve GOV.UK?", :with => "test feedback"
    select "Test Department", :from => "Is there a section your feedback relates to?"
    click_on "submit"

    i_should_be_on "/feedback/general-feedback"

    page.should have_content("Thank you for your help.")

    expected_description = "test feedback"
    zendesk_should_have_ticket :subject => "General Feedback",
      :name => "test name",
      :email => "a@a.com",
      :department => "test_department",
      :description => expected_description,
      :tags => ['general_feedback']
  end
end
