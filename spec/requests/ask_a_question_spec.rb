require 'spec_helper'

describe "Ask a question" do

  it "should let the user submit a question" do
    visit "/feedback/ask-a-question"

    fill_in "Name", :with => "test name"
    fill_in "Email", :with => "a@a.com"
    fill_in "Verify email", :with => "a@a.com"
    fill_in "What can we help you with?", :with => "test question"
    select "Test Department", :from => "Is there a section where you'd expect to find an answer?"
    fill_in "Please list any search terms you used to help us improve GOV.UK.", :with => "test search-terms"
    click_on "submit"

    i_should_be_on "/feedback/ask-a-question"

    page.should have_content("Thank you for your help.")

    expected_description = \
      "[Question]\n"\
      "test question\n"\
      "[Search Terms]\n"\
      "test search-terms"
    zendesk_should_have_ticket :subject => "Ask a Question",
      :name => "test name",
      :email => "a@a.com",
      :department => "test_department",
      :description => expected_description,
      :tags => ['ask_question']

  end

  it "should not proceed if the user hasn't filled in all required question fields" do
    visit "/feedback/ask-a-question"

    fill_in "Name", :with => "test name"
    fill_in "Email", :with => "a@a.com"
    fill_in "Verify email", :with => "a@a.com"
    select "Test Department", :from => "Is there a section where you'd expect to find an answer?"
    fill_in "Please list any search terms you used to help us improve GOV.UK.", :with => "test search-terms"
    click_on "submit"

    i_should_be_on "/feedback/ask-a-question"

    find_field('Name').value.should eq 'test name'
    find_field('Email').value.should eq 'a@a.com'
    find_field('Verify email').value.should eq 'a@a.com'
    find_field('Please list any search terms you used to help us improve GOV.UK.').value.should eq 'test search-terms'

    zendesk_should_not_have_ticket
  end

  it "should show an error page if there is a zendesk error" do
    visit "/feedback/ask-a-question"

    given_zendesk_ticket_creation_fails

    fill_in "Name", :with => "name"
    fill_in "Email", :with => "a@a.com"
    fill_in "Verify email", :with => "a@a.com"
    fill_in "What can we help you with?", :with => "test question"
    select "Test Department", :from => "Is there a section where you'd expect to find an answer?"
    fill_in "Please list any search terms you used to help us improve GOV.UK.", :with => "test search-terms"
    click_on "submit"

    i_should_be_on "/feedback/ask-a-question"

   expected_description = \
      "[Question]\n"\
      "test question\n"\
      "[Search Terms]\n"\
      "test search-terms"
    zendesk_should_have_ticket :subject => "Ask a Question",
      :name => "name",
      :email => "a@a.com",
      :department => "test_department",
      :description => expected_description,
      :tags => ['ask_question']
  end

end
