require 'spec_helper'

describe "The feedback page" do

  it "should display successfully" do
    visit "/feedback"

    within("title") { page.should have_content("Feedback | Help | GOV.UK") }

    page.should have_content("Feedback")
    page.should have_content("Help us improve GOV.UK")

    within "nav[role=navigation] ol li:last-child" do
      page.should have_link("Feedback", :href => "/feedback")
    end
  end
end
