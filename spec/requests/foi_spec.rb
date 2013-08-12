require 'spec_helper'
require 'gds_api/test_helpers/support'

describe "FOI" do
  include GdsApi::TestHelpers::Support

  def fill_in_valid_credentials
    fill_in "Your name", :with => "test name"
    fill_in "Your email address", :with => "a@a.com"
    fill_in "Confirm your email address", :with => "a@a.com"
  end

  it "should let the user submit a FOI request" do
    stub_post = stub_support_foi_request_creation(requester: {name: "test name", email: "a@a.com"}, details: "test foi request")

    visit "/feedback/foi"

    fill_in "Your name", :with => "test name"
    fill_in "Your email address", :with => "a@a.com"
    fill_in "Confirm your email address", :with => "a@a.com"
    fill_in "Provide a detailed description of the information you're seeking", :with => "test foi request"
    click_on "Submit Freedom of Information request"

    i_should_be_on "/feedback/foi"

    page.should have_content("Your message has been sent, and the team will get back to you to answer any questions as soon as possible.")
    assert_requested(stub_post)
  end

  it "recreate non-UTF-char bug" do
    stub_support_foi_request_creation

    visit "/feedback/foi"

    fill_in_valid_credentials
    fill_in "Provide a detailed description of the information you're seeking", :with => "\xFF\xFEother data"
    click_on "Submit Freedom of Information request"

    i_should_be_on "/feedback/foi"
  end

  it "should not accept spam (ie requests with val field filled in)" do
    visit "/feedback/foi"

    fill_in "Your name", :with => "test name"
    fill_in "Your email address", :with => "a@a.com"
    fill_in "Confirm your email address", :with => "a@a.com"
    fill_in "Provide a detailed description of the information you're seeking", :with => "test foi request"
    fill_in "val", :with => "test val"
    click_on "Submit Freedom of Information request"

    page.status_code.should == 400
  end

  it "should show an error message when the zendesk connection fails" do
    support_isnt_available

    visit "/feedback/foi"

    fill_in "Your name", :with => "test name"
    fill_in "Your email address", :with => "a@a.com"
    fill_in "Confirm your email address", :with => "a@a.com"
    fill_in "Provide a detailed description of the information you're seeking", :with => "test foi request"
    click_on "Submit Freedom of Information request"

    i_should_be_on "/feedback/foi"

    page.status_code.should == 503
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
