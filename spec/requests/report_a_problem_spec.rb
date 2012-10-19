require 'spec_helper'

describe "Reporting a problem with this content/tool" do

  it "should let the user submit a response to zendesk" do
    visit "/test_forms/report_a_problem"

    fill_in "What you were doing", :with => "I was doing something"
    fill_in "What is wrong with this page", :with => "It didn't work"
    click_on "Send"

    i_should_be_on "/feedback"

    page.should have_content("Thank you for your help.")
    page.should have_link("Return to where you were", :href => "/test_forms/report_a_problem")

    expected_description = <<-EOT
url: http://www.example.com/test_forms/report_a_problem
what_doing: I was doing something
what_wrong: It didn't work
user_agent: unknown
    EOT
    zendesk_should_have_ticket :subject => "/test_forms/report_a_problem", :description => expected_description, :tags => ['report_a_problem']
  end

  it "should include the user_agent if available" do
    # This nasty hack is taken from https://github.com/jnicklas/capybara/pull/382
    options = page.driver.instance_variable_get("@options")
    orig_options = options.dup
    options[:headers] = {"HTTP_USER_AGENT" => "Shamfari/3.14159 (Fooey)"}
    page.driver.instance_variable_set "@options", options

    visit "/test_forms/report_a_problem"

    fill_in "What you were doing", :with => "I was doing something"
    fill_in "What is wrong with this page", :with => "It didn't work"
    click_on "Send"

    i_should_be_on "/feedback"

    page.should have_content("Thank you for your help.")

    expected_description = <<-EOT
url: http://www.example.com/test_forms/report_a_problem
what_doing: I was doing something
what_wrong: It didn't work
user_agent: Shamfari/3.14159 (Fooey)
    EOT
    zendesk_should_have_ticket :subject => "/test_forms/report_a_problem", :description => expected_description, :tags => ['report_a_problem']

    page.driver.instance_variable_set "@options", orig_options
  end

  it "should handle errors submitting tickets to zendesk" do
    given_zendesk_ticket_creation_fails

    visit "/test_forms/report_a_problem"

    fill_in "What you were doing", :with => "I was doing something"
    fill_in "What is wrong with this page", :with => "It didn't work"
    click_on "Send"

    i_should_be_on "/feedback"

    page.should have_content("Sorry, we're unable to receive your message right now.")
    page.should have_link("support page", :href => "/feedback")
    page.should have_link("Return to where you were", :href => "/test_forms/report_a_problem")
  end
end
