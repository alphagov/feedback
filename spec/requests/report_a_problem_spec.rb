require 'spec_helper'

describe "Report a problem" do

  it "should let the user report a problem" do
    visit "/feedback/report-a-problem"

    fill_in "What were you doing?", :with => "test what was done"
    fill_in "What is wrong?", :with => "test what is wrong"
    fill_in "What page did you have problems with?", :with => "http://test.com/test/page"
    click_on "submit"

    i_should_be_on "/feedback/report-a-problem"

    page.should have_content("Thank you for your help.")

    expected_description = "url: http://test.com/test/page\nwhat_doing: test what was done\nwhat_wrong: test what is wrong"
    zendesk_should_have_ticket :subject => "/test/page",
      :description => expected_description,
      :tags => ['report_a_problem']
  end

  it "should let the user report a problem without a URL" do
    visit "/feedback/report-a-problem"

    fill_in "What were you doing?", :with => "test what was done"
    fill_in "What is wrong?", :with => "test what is wrong"
    click_on "submit"

    i_should_be_on "/feedback/report-a-problem"

    page.should have_content("Thank you for your help.")

    expected_description = "url: \nwhat_doing: test what was done\nwhat_wrong: test what is wrong"
    zendesk_should_have_ticket :subject => "Unknown page",
      :description => expected_description,
      :tags => ['report_a_problem']
  end

  it "should let the user report a problem with invalid URL" do
    visit "/feedback/report-a-problem"

    fill_in "What were you doing?", :with => "test what was done"
    fill_in "What is wrong?", :with => "test what is wrong"
    fill_in "What page did you have problems with?", :with => "[Cslss"
    click_on "submit"

    i_should_be_on "/feedback/report-a-problem"

    page.should have_content("Thank you for your help.")

    expected_description = "url: [Cslss\nwhat_doing: test what was done\nwhat_wrong: test what is wrong"
    zendesk_should_have_ticket :subject => "Unknown page",
      :description => expected_description,
      :tags => ['report_a_problem']
  end

  it "should not proceed if the user hasn't filled in all required report a problem fields" do
    visit "/feedback/report-a-problem"

    fill_in "What were you doing?", :with => "test what was done"
    fill_in "What page did you have problems with?", :with => "http://test.com/test/page"
    click_on "submit"

    i_should_be_on "/feedback/report-a-problem"


    find_field('What were you doing?').value.should eq 'test what was done'
    find_field('What page did you have problems with?').value.should eq 'http://test.com/test/page'

    zendesk_should_not_have_ticket
  end

  it "should let the user submit a response to zendesk" do
    visit "/test_forms/report_a_problem"

    fill_in "What you were doing", :with => "I was doing something"
    fill_in "What is wrong with this page", :with => "It didn't work"
    click_on "Send"

    i_should_be_on "/feedback"

    page.should have_content("Thank you for your help.")
    page.should have_link("Return to where you were", :href => "/test_forms/report_a_problem")

    expected_description = "url: http://www.example.com/test_forms/report_a_problem\n"\
      "what_doing: I was doing something\n"\
      "what_wrong: It didn't work"
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
