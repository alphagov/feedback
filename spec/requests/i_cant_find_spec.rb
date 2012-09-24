require 'spec_helper'

describe "I can't find" do

  it "should let the user make an I can't find request" do
    visit "/feedback/i-cant-find"

    fill_in "Name", :with => "test name"
    fill_in "Email", :with => "a@a.com"
    fill_in "Verify email", :with => "a@a.com"
    fill_in "What are you looking for?", :with => "test looking"
    select "Test Department", :from => "Where would you expect to find it?"
    fill_in "Please list any search terms you used to help us improve GOV.UK.", :with => "test search terms"
    fill_in "If you normally use a link to access the above information, please list it here.", :with => "http://test.com"
    click_on "submit"

    i_should_be_on "/feedback/i-cant-find"

    page.should have_content("Thank you for your help.")

    expected_description = "[Looking For]\ntest looking\n[Link]\nhttp://test.com\n[Search Terms]\ntest search terms"
    zendesk_should_have_ticket :subject => "I can't find",
      :name => "test name",
      :email => "a@a.com",
      :department => "test_department",
      :description => expected_description,
      :tags => ['i_cant_find']
  end

  it "should not proceed if the user hasn't filled in all required I can't find fields" do
    visit "/feedback/i-cant-find"

    fill_in "Name", :with => "test name"
    fill_in "Email", :with => "a@a.com"
    fill_in "Verify email", :with => "a@a.com"
    select "Test Department", :from => "Where would you expect to find it?"
    fill_in "Please list any search terms you used to help us improve GOV.UK.", :with => "test search terms"
    fill_in "If you normally use a link to access the above information, please list it here.", :with => "http://test.com"
    click_on "submit"

    i_should_be_on "/feedback/i-cant-find"
    find_field('Name').value.should eq 'test name'
    find_field('Email').value.should eq 'a@a.com'
    find_field('Verify email').value.should eq 'a@a.com'
    find_field('Please list any search terms you used to help us improve GOV.UK.').value.should eq 'test search terms'
    find_field('If you normally use a link to access the above information, please list it here.').value.should eq 'http://test.com'

    zendesk_should_not_have_ticket
  end
end
