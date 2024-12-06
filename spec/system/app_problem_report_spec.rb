require "rails_helper"
require "gds_api/test_helpers/support_api"

RSpec.describe "Submitting app problem report" do
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
  end

  context "when selecting report a problem" do
    before do
      visit "/contact/govuk-app?app_version=1.0&phone=Apple+iPhone+15+pro+18.1"
      choose("Report a problem with the app")
      click_on("Continue")
    end

    it "redirects to the problem report form" do
      expect(page.current_path).to eq("/contact/govuk-app/report-problem")
    end

    it "has the correct title" do
      expect(page).to have_title("Report a problem with the GOV.UK app")
    end

    it "includes phone field" do
      expect(page).to have_field("What phone do you have?")
    end

    it "populates phone field with phone query param" do
      expect(page.find("#phone").value).to eq("Apple iPhone 15 pro 18.1")
    end

    it "includes app version field" do
      expect(page).to have_field("The app version where you found the problem")
    end

    it "populates app version field with app_version query param" do
      expect(page.find("#app_version").value).to eq("1.0")
    end

    it "includes what you were trying to do field" do
      expect(page).to have_field("What were you trying to do?")
    end

    it "includes what happened field" do
      expect(page).to have_field("What happened?")
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
      ga4_expected_object = "{\"event_name\":\"form_response\",\"type\":\"contact\",\"section\":\"What phone do you have?, The app version where you found the problem, What were you trying to do?, What happened?, Can we reply to you by email?, Email address, Your name\",\"action\":\"Send message\",\"tool_name\":\"Contact the GOV.UK app team\"}"

      expect(data_module).to eq(expected_data_module)
      expect(ga4_form_attribute).to eq(ga4_expected_object)
    end
  end

  context "when submitting a valid problem report" do
    context "with all fields populated" do
      let(:stub_raising_valid_support_ticket) do
        body = <<~MULTILINE_STRING
          [Requester]
          Zeus <something@example.com>

          [Phone]
          iPhone 15

          [App version]
          1.0

          [What were you trying to do?]
          Trying to do something

          [What happened?]
          Something bad
        MULTILINE_STRING

        stub_support_api_valid_raise_support_ticket(
          {
            subject: "Problem report",
            priority: "normal",
            tags: %w[govuk_app govuk_app_problem_report],
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
        visit "/contact/govuk-app/report-problem"
        fill_in("What phone do you have?", with: "iPhone 15")
        fill_in("The app version where you found the problem", with: "1.0")
        fill_in("What were you trying to do?", with: "Trying to do something")
        fill_in("What happened?", with: "Something bad")
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
    end

    context "with only the required fields populated" do
      let(:stub_raising_valid_support_ticket_anonymous) do
        body = <<~MULTILINE_STRING
          [Requester]
          Anonymous

          [Phone]
          Not submitted

          [App version]
          Not submitted

          [What were you trying to do?]
          Trying to do something

          [What happened?]
          Something bad
        MULTILINE_STRING

        stub_support_api_valid_raise_support_ticket(
          {
            subject: "Problem report",
            tags: %w[govuk_app govuk_app_problem_report],
            priority: "normal",
            description: body,
            requester: nil,
          },
        )
      end

      before do
        stub_raising_valid_support_ticket_anonymous
        visit "/contact/govuk-app/report-problem"
        fill_in("What were you trying to do?", with: "Trying to do something")
        fill_in("What happened?", with: "Something bad")
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

  context "when submitting an invalid problem report" do
    before do
      visit "/contact/govuk-app/report-problem"
      fill_in("What happened?", with: "Something bad")
      click_on("Send message")
    end

    it "renders the problem report page" do
      expect(page.current_path).to eq("/contact/govuk-app/report-problem")
    end

    it "includes an error summary" do
      within(".gem-c-error-summary") do
        expect(page).to have_content("Select yes if you want a reply")
        expect(page).to have_content("Enter details about what you were trying to do")
      end
    end

    it "adds GA4 attributes to error summary" do
      auto_tracker_element = page.find("div[data-module=ga4-auto-tracker]")
      ga4_auto_attribute = auto_tracker_element["data-ga4-auto"]
      ga4_expected_object = "{\"event_name\":\"form_error\",\"type\":\"contact\",\"action\":\"error\",\"text\":\"Select yes if you want a reply, Enter details about what you were trying to do\",\"section\":\"Can we reply to you by email?, What were you trying to do?\",\"tool_name\":\"Contact the GOV.UK app team\"}"

      expect(ga4_auto_attribute).to eq(ga4_expected_object)
    end

    it "includes field error for what you were trying to do" do
      within all(".gem-c-character-count")[0] do
        expect(page).to have_content("What were you trying to do?")
        expect(page).to have_content("Enter details about what you were trying to do")
      end
    end

    it "includes field error for reply option" do
      within("#reply") do
        expect(page).to have_content("Can we reply to you by email?")
        expect(page).to have_content("Select yes if you want a reply")
      end
    end

    it "populates previously submitted field" do
      expect(page).to have_field("What happened?", with: "Something bad")
    end
  end
end
