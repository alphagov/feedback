require 'spec_helper'

describe "The feedback page" do

  it "should display successfully" do
    visit "/feedback"

    page.should have_content("Feedback")
    page.should have_content("Help us improve GOV.UK")
  end
end
