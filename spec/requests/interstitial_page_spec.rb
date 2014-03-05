require 'spec_helper'

describe "Interstitial page" do
  it "should display popular contact links" do
    visit "/contact"

    POPULAR_CONTACT_LINKS.each do |link|
      expect(page).to have_link(link["Title"], href: link["URL"])
    end
  end
end
