require "rails_helper"
require "gds_api/test_helpers/support_api"

RSpec.describe "Submitting app chat feedback" do
  include GdsApi::TestHelpers::SupportApi

  context "when visiting the landing page" do
    before do
      visit "/contact/govuk-app"
    end

    it "adds GA4 attributes for form submit events" do
      data_module = page.find("form")["data-module"]
      expected_data_module = "ga4-form-tracker"
      ga4_form_attribute = page.find("form")["data-ga4-form"]
      ga4_expected_object = "{\"event_name\":\"form_response\",\"type\":\"contact\",\"section\":\"What would you like to do?\",\"action\":\"Continue\",\"tool_name\":\"Contact the GOV.UK app team\"}"

      expect(data_module).to eq(expected_data_module)
      expect(ga4_form_attribute).to eq(ga4_expected_object)
    end

    it "shows govuk app contact start page" do
      expect(page).to have_title("Contact the GOV.UK app team")
      expect(page).to have_content("What would you like to do?")
    end

    it "adds noindex meta tag" do
      expect(page).to have_selector('meta[name=robots][content="noindex"]', visible: false)
    end
  end

  context "when selecting chat feedback" do
    before do
      visit "/contact/govuk-app"
      choose("Leave feedback about GOV.UK Chat")
      click_on("Continue")
    end

    it "redirects to the chat feedback form" do
      expect(page.current_path).to eq("/contact/govuk-app/leave-feedback-about-govuk-chat")
    end

    it "has the correct title" do
      expect(page).to have_title("Leave feedback about GOV.UK Chat")
    end

    it "includes feedback field" do
      expect(page).to have_field("Please leave your feedback")
    end

    it "includes reply option" do
      expect(page).to have_content("Can we reply to you by email?")
      within(".govuk-radios") do
        expect(page).to have_unchecked_field("Yes")
        expect(page).to have_field("Email address")
        expect(page).to have_field("Your name")
        expect(page).to have_unchecked_field("No")
      end
    end

    it "adds GA4 attributes for form submit events" do
      data_module = page.find("form")["data-module"]
      expected_data_module = "ga4-form-tracker"
      ga4_form_attribute = page.find("form")["data-ga4-form"]
      ga4_expected_object = "{\"event_name\":\"form_response\",\"type\":\"contact\",\"section\":\"Please leave your feedback, Can we reply to you by email?, Email address, Your name\",\"action\":\"Send feedback\",\"tool_name\":\"Leave feedback about GOV.UK Chat\"}"

      expect(data_module).to eq(expected_data_module)
      expect(ga4_form_attribute).to eq(ga4_expected_object)
    end

    it "adds noindex meta tag" do
      expect(page).to have_selector('meta[name=robots][content="noindex"]', visible: false)
    end
  end

  context "when submitting valid chat feedback" do
    context "with all fields populated" do
      let(:stub_raising_valid_support_ticket) do
        body = <<~MULTILINE_STRING
          [Requester]
          Zeus <something@example.com>

          [Please leave your feedback]
          Some feedback
        MULTILINE_STRING

        stub_support_api_valid_raise_support_ticket(
          {
            subject: "Leave feedback about GOV.UK Chat",
            priority: "normal",
            tags: %w[govuk_app govuk_app_chat],
            description: body,
            requester: {
              email: "something@example.com",
              name: "Zeus",
            },
          },
        )
      end

      before do
        stub_raising_valid_support_ticket
        visit "/contact/govuk-app/leave-feedback-about-govuk-chat"
        fill_in("feedback", with: "Some feedback")
        choose("Yes")
        fill_in("Email", with: "something@example.com")
        fill_in("Your name", with: "Zeus")
        click_on("Send feedback")
      end

      it "redirects to confirmation page" do
        expect(page.current_path).to eq("/contact/govuk-app/confirmation")
      end

      it "confirms the submission" do
        expect(page).to have_content("Your message has been submitted")
      end

      it "adds noindex meta tag" do
        expect(page).to have_selector('meta[name=robots][content="noindex"]', visible: false)
      end
    end
  end

  context "when submitting invalid chat feedback" do
    before do
      visit "/contact/govuk-app/leave-feedback-about-govuk-chat"
      click_on("Send feedback")
    end

    it "renders the chat feedback page" do
      expect(page.current_path).to eq("/contact/govuk-app/leave-feedback-about-govuk-chat")
    end

    it "includes an error summary" do
      within(".gem-c-error-summary") do
        expect(page).to have_content("Select yes if you want a reply")
        expect(page).to have_content("Enter your feedback")
      end
    end

    it "adds GA4 attributes to error summary" do
      auto_tracker_element = page.find("div[data-module=ga4-auto-tracker]")
      ga4_auto_attribute = auto_tracker_element["data-ga4-auto"]
      ga4_expected_object = "{\"event_name\":\"form_error\",\"type\":\"contact\",\"action\":\"error\",\"text\":\"Select yes if you want a reply, Enter your feedback\",\"section\":\"Can we reply to you by email?, Please leave your feedback\",\"tool_name\":\"Leave feedback about GOV.UK Chat\"}"

      expect(ga4_auto_attribute).to eq(ga4_expected_object)
    end

    it "includes field error for what you were trying to do" do
      within all(".gem-c-character-count")[0] do
        expect(page).to have_content("Enter your feedback")
      end
    end

    it "includes field error for reply option" do
      within("#reply") do
        expect(page).to have_content("Can we reply to you by email?")
        expect(page).to have_content("Select yes if you want a reply")
      end
    end
  end
end
