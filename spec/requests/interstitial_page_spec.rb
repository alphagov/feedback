require 'spec_helper'

describe "Interstitial page" do
  it "should display popular contact links" do
    visit "/contact"

    CONTACT_LINKS.popular.each do |link|
      expect(page).to have_link(link["Title"], href: link["URL"])
    end
  end
end
