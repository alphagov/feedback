require "rails_helper"

RSpec.describe "GOV.UK App", type: :request do
  context "#new" do
    it "should display new page" do
      visit "/contact/govuk-app"
      expect(page).to have_title "Contact the GOV.UK app team"
    end
  end

  context "#create" do
    it "should redirect to problem report form given problem type" do
      post "/contact/govuk-app", params: { contact: { type: "problem" } }

      follow_redirect!

      expect(response.body).to include(
        I18n.t("controllers.contact.govuk_app.problem_reports.new.title"),
      )
    end

    it "should render suggestions form given suggestion type" do
      post "/contact/govuk-app", params: { contact: { type: "suggestion" } }

      follow_redirect!

      expect(response.body).to include(
        I18n.t("controllers.contact.govuk_app.suggestions.new.title"),
      )
    end
  end

  context "#confirmation" do
    it "should display confirmation page" do
      get "/contact/govuk-app/confirmation"
      expect(response.body).to include(
        I18n.t("controllers.contact.govuk_app.confirmation.message"),
      )
    end
  end
end
