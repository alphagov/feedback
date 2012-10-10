require 'spec_helper'

describe "FOI" do

  it "should let the user submit a FOI request" do
    visit "/feedback/foi"

    fill_in "Your name", :with => "test name"
    fill_in "Your email address", :with => "a@a.com"
    fill_in "Confirm your email address", :with => "a@a.com"
    fill_in "Provide a detailed description of the information you're seeking", :with => "test foi request"
    click_on "Submit Freedom of Information request"

    i_should_be_on "/feedback/foi"

    page.should have_content("Your message has been sent, and the team will get back to you to answer any questions as soon as possible.")

    expected_description = "[Name]\ntest name\n[Details]\ntest foi request"
    zendesk_should_have_ticket :subject => "FOI",
      :name => "test name",
      :email => "a@a.com",
      :description => expected_description,
      :tags => ['FOI_request']
  end

  it "should show an error message when the zendesk connection fails" do

    given_zendesk_ticket_creation_fails
    visit "/feedback/foi"

    fill_in "Your name", :with => "test name"
    fill_in "Your email address", :with => "a@a.com"
    fill_in "Confirm your email address", :with => "a@a.com"
    fill_in "Provide a detailed description of the information you're seeking", :with => "test foi request"
    click_on "Submit Freedom of Information request"

    i_should_be_on "/feedback/foi"

    page.should have_content("Sorry, but we have been unable to send your message.")

    expected_description = "[Name]\ntest name\n[Details]\ntest foi request"
    zendesk_should_have_ticket :subject => "FOI",
                               :name => "test name",
                               :email => "a@a.com",
                               :description => expected_description,
                               :tags => ['FOI_request']
    ActionMailer::Base.deliveries.last.to.should == ["govuk-exceptions@digital.cabinet-office.gov.uk"]
  end

  it "should not proceed if the user hasn't filled in all required FOI fields" do
    visit "/feedback/foi"

    fill_in "Your name", :with => "test name"
    fill_in "Your email address", :with => "a@a.com"
    fill_in "Confirm your email address", :with => "a@a.com"
    click_on "Submit Freedom of Information request"

    i_should_be_on "/feedback/foi"

    find_field('Your name').value.should eq 'test name'
    find_field('Your email address').value.should eq 'a@a.com'
    find_field('Confirm your email address').value.should eq 'a@a.com'

    zendesk_should_not_have_ticket
  end

end
