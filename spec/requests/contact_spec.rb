require 'spec_helper'

describe "Contact" do

  it "should let the user submit an 'ask a question' request" do
    visit "/feedback/contact"

    choose "location-all"
    choose "ask-question"
    fill_in "Your name", :with => "test name"
    fill_in "Your email address", :with => "a@a.com"
    fill_in "textdetails", :with => "test text details"
    click_on "Send message"

    i_should_be_on "/feedback/contact"

    page.should have_content("Thank you for your help.")

    expected_description = "[Location]\nall\n[Name]\ntest name\n[Details]\ntest text details"
    zendesk_should_have_ticket :subject => "Ask a question",
      :name => "test name",
      :email => "a@a.com",
      :description => expected_description,
      :tags => ['ask_question']
  end

  it "should let the user submit an 'I can't find' request" do
    visit "/feedback/contact"

    choose "location-section"
    choose "cant-find"
    fill_in "Your name", :with => "test name"
    fill_in "Your email address", :with => "a@a.com"
    fill_in "textdetails", :with => "test text details"
    click_on "Send message"

    i_should_be_on "/feedback/contact"

    page.should have_content("Thank you for your help.")

    expected_description = "[Location]\nsection\n[Name]\ntest name\n[Details]\ntest text details"
    zendesk_should_have_ticket :subject => "I can't find",
                               :name => "test name",
                               :email => "a@a.com",
                               :section => "test_section",
                               :description => expected_description,
                               :tags => ['i_cant_find']
  end

  it "should let the user submit a 'report a problem' request" do
    visit "/feedback/contact"

    choose "location-specific"
    choose "report-problem"
    fill_in "Your name", :with => "test name"
    fill_in "Your email address", :with => "a@a.com"
    fill_in "textdetails", :with => "test text details"
    fill_in "link", :with => "some url"
    click_on "Send message"

    i_should_be_on "/feedback/contact"

    page.should have_content("Thank you for your help.")

    expected_description = "[Location]\nspecific\n[Link]\nsome url\n[Name]\ntest name\n[Details]\ntest text details"
    zendesk_should_have_ticket :subject => "Report a problem",
                               :name => "test name",
                               :email => "a@a.com",
                               :description => expected_description,
                               :tags => ['report_a_problem_public']
  end

  it "should let the user submit a 'make suggestion' request" do
    visit "/feedback/contact"

    choose "location-specific"
    choose "make-suggestion"
    fill_in "Your name", :with => "test name"
    fill_in "Your email address", :with => "a@a.com"
    fill_in "textdetails", :with => "test text details"
    fill_in "link", :with => "some url"
    click_on "Send message"

    i_should_be_on "/feedback/contact"

    page.should have_content("Thank you for your help.")

    expected_description = "[Location]\nspecific\n[Link]\nsome url\n[Name]\ntest name\n[Details]\ntest text details"
    zendesk_should_have_ticket :subject => "General feedback",
                               :name => "test name",
                               :email => "a@a.com",
                               :description => expected_description,
                               :tags => ['general_feedback']
  end

  it "should show an error message when the zendesk connection fails" do

    given_zendesk_ticket_creation_fails

    visit "/feedback/contact"

    choose "location-specific"
    choose "make-suggestion"
    fill_in "Your name", :with => "test name"
    fill_in "Your email address", :with => "a@a.com"
    fill_in "textdetails", :with => "test text details"
    fill_in "link", :with => "some url"
    click_on "Send message"

    i_should_be_on "/feedback/contact"

    page.should have_content("Sorry, we're unable to receive your message right now")

    expected_description = "[Location]\nspecific\n[Link]\nsome url\n[Name]\ntest name\n[Details]\ntest text details"
    zendesk_should_have_ticket :subject => "General feedback",
                               :name => "test name",
                               :email => "a@a.com",
                               :description => expected_description,
                               :tags => ['general_feedback']

  end

  it "should not proceed if the user hasn't filled in all required fields" do
    visit "/feedback/contact"

    choose "location-all"
    fill_in "Your name", :with => "test name"
    fill_in "Your email address", :with => "a@a.com"
    click_on "Send message"

    i_should_be_on "/feedback/contact"

    find_field('Your name').value.should eq 'test name'
    find_field('Your email address').value.should eq 'a@a.com'

    zendesk_should_not_have_ticket
  end

end
