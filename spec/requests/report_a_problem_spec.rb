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
end
