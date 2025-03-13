require "rails_helper"
require "gds_api/test_helpers/support_api"

RSpec.describe "Submitting a suggestion" do
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

  context "when selecting report a problem" do
    before do
      visit "/contact/govuk-app"
      choose("Make a suggestion for improving the app")
      click_on("Continue")
    end

    it "redirects to the suggestion form" do
      expect(page.current_path).to eq("/contact/govuk-app/make-suggestion")
    end

    it "has the correct title" do
      expect(page).to have_title("Make a suggestion about the GOV.UK app")
    end

    it "includes suggestion field" do
      expect(page).to have_field("What is your suggestion?")
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
      ga4_expected_object = "{\"event_name\":\"form_response\",\"type\":\"contact\",\"section\":\"What is your suggestion?, Can we reply to you by email?, Email address, Your name\",\"action\":\"Send message\",\"tool_name\":\"Contact the GOV.UK app team\"}"

      expect(data_module).to eq(expected_data_module)
      expect(ga4_form_attribute).to eq(ga4_expected_object)
    end

    it "adds noindex meta tag" do
      expect(page).to have_selector('meta[name=robots][content="noindex"]', visible: false)
    end
  end

  context "when submitting a valid suggestion" do
    context "with all fields populated" do
      let(:stub_raising_valid_support_ticket) do
        body = <<~MULTILINE_STRING
          [Requester]
          Zeus <something@example.com>

          [What is your suggestion?]
          A good one
        MULTILINE_STRING

        stub_support_api_valid_raise_support_ticket(
          {
            subject: "Suggestion",
            priority: "normal",
            tags: %w[govuk_app govuk_app_suggestion],
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
        visit "/contact/govuk-app/make-suggestion"
        fill_in("What is your suggestion?", with: "A good one")
        choose("Yes")
        fill_in("Email", with: "something@example.com")
        fill_in("Your name", with: "Zeus")
        click_on("Send message")
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

    context "without wanting a reply" do
      let(:stub_raising_valid_support_ticket_anonymous) do
        body = <<~MULTILINE_STRING
          [Requester]
          Anonymous

          [What is your suggestion?]
          A good one
        MULTILINE_STRING

        stub_support_api_valid_raise_support_ticket(
          {
            subject: "Suggestion",
            tags: %w[govuk_app govuk_app_suggestion],
            priority: "normal",
            description: body,
            requester: nil,
          },
        )
      end

      before do
        stub_raising_valid_support_ticket_anonymous
        visit "/contact/govuk-app/make-suggestion"
        fill_in("What is your suggestion?", with: "A good one")
        choose("No")
        click_on("Send message")
      end

      it "redirects to confirmation page" do
        expect(page.current_path).to eq("/contact/govuk-app/confirmation")
      end

      it "confirms the submission" do
        expect(page).to have_content("Your message has been submitted")
      end
    end
  end

  context "when submitting an invalid suggestion" do
    before do
      visit "/contact/govuk-app/make-suggestion"
      choose("Yes")
      fill_in("Your name", with: "Zeus")
      click_on("Send message")
    end

    it "renders the problem report page" do
      expect(page.current_path).to eq("/contact/govuk-app/make-suggestion")
    end

    it "includes an error summary" do
      within(".gem-c-error-summary") do
        expect(page).to have_content("Enter an email address")
        expect(page).to have_content("Enter your suggestion")
      end
    end

    it "adds GA4 attributes to error summary" do
      auto_tracker_element = page.find("div[data-module=ga4-auto-tracker]")
      ga4_auto_attribute = auto_tracker_element["data-ga4-auto"]
      ga4_expected_object = "{\"event_name\":\"form_error\",\"type\":\"contact\",\"action\":\"error\",\"text\":\"Enter an email address, Enter your suggestion\",\"section\":\"Email address, What is your suggestion?\",\"tool_name\":\"Contact the GOV.UK app team\"}"

      expect(ga4_auto_attribute).to eq(ga4_expected_object)
    end

    it "includes field error for your suggestion" do
      within all(".gem-c-character-count")[0] do
        expect(page).to have_content("What is your suggestion?")
        expect(page).to have_content("Enter your suggestion")
      end
    end

    it "includes field error for reply option" do
      within("#reply") do
        expect(page).to have_content("Can we reply to you by email?")
        expect(page).to have_content("Enter an email address")
      end
    end

    it "populates previously submitted field" do
      expect(page).to have_field("Your name", with: "Zeus")
    end
  end
end
