require 'spec_helper'

describe "Interstitial page" do
  it "should display popular contact links" do
    visit "/contact"

    within "#popular-links" do
      CONTACT_LINKS.popular.each do |link|
        expect(page).to have_link(link["Title"], href: link["URL"])
      end
    end
  end

  it "should display popular contact links" do
    visit "/contact"    

    within "#long-tail-links" do
      CONTACT_LINKS.long_tail.each do |link|
        expect(page).to have_link(link["Title"], href: link["URL"])
      end
    end
  end
end
