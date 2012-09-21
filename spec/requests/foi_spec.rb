require 'spec_helper'

describe "FOI" do

  it "should let the user submit a FOI request" do
    visit "/feedback/foi"

    fill_in "Name", :with => "test name"
    fill_in "Email", :with => "a@a.com"
    fill_in "Verify email", :with => "a@a.com"
    fill_in "Provide a detailed description about the information you're seeking", :with => "test foi request"
    click_on "submit"

    i_should_be_on "/feedback/foi"

    page.should have_content("Thank you for your help.")

    expected_description = "test foi request"
    zendesk_should_have_ticket :subject => "FOI",
      :name => "test name",
      :email => "a@a.com",
      :description => expected_description,
      :tags => ['FOI_request']
  end

  it "should not proceed if the user hasn't filled in all required FOI fields" do
    visit "/feedback/foi"

    fill_in "Name", :with => "test name"
    fill_in "Email", :with => "a@a.com"
    fill_in "Verify email", :with => "a@a.com"
    click_on "submit"

    i_should_be_on "/feedback/foi"

    find_field('Name').value.should eq 'test name'
    find_field('Email').value.should eq 'a@a.com'
    find_field('Verify email').value.should eq 'a@a.com'

    zendesk_should_not_have_ticket
  end

end
