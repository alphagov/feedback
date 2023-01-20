require "rails_helper"
require "gds_api/test_helpers/support"
require "gds_api/test_helpers/support_api"
require "gds_api/test_helpers/content_store"

RSpec.describe "Service feedback submission", type: :request do
  include GdsApi::TestHelpers::Support
  include GdsApi::TestHelpers::SupportApi
  include GdsApi::TestHelpers::ContentStore

  let(:payload) do
    {
      base_path: "/done/some-transaction",
      schema_name: "completed_transaction",
      document_type: "completed_transaction",
      external_related_links: [],
      title: "Some Transaction",
    }
  end

  before do
    stub_content_store_has_item("/#{slug}", schema_name: format)
  end

  context "render a Service Feedback form" do
    it "displays title from the completed transaction's content item" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/some-transaction")

      expect(page).to have_content("Some Transaction")
    end

    # Runs specs in support/service_feedback.rb
    include_examples "Service Feedback", "/done/some-transaction"

    it "displays service satisfaction rating radio buttons" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/some-transaction")

      expect(page).to have_content(I18n.translate("controllers.contact.govuk.service_feedback.service_satisfaction_rating"))
      expect(page).to have_field("service-satisfaction-rating-0", type: "radio")
      expect(page).to have_field("service-satisfaction-rating-1", type: "radio")
      expect(page).to have_field("service-satisfaction-rating-2", type: "radio")
      expect(page).to have_field("service-satisfaction-rating-3", type: "radio")
      expect(page).to have_field("service-satisfaction-rating-4", type: "radio")
    end

    it "displays service feedback improvement comments text area" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/some-transaction")
      expect(page).to have_field(I18n.translate("controllers.contact.govuk.service_feedback.how_improve", type: "textarea"))
      expect(page).to have_content(I18n.translate("controllers.contact.govuk.service_feedback.no_pii_hint"))
    end
  end

  context "form submission" do
    before do
      stub_support_api_service_feedback_creation
    end

    it "submits with valid data" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/some-transaction")
      within(".service-feedback") do
        choose I18n.translate("controllers.contact.govuk.service_feedback.very_satisfied")
        fill_in I18n.translate("controllers.contact.govuk.service_feedback.how_improve"), with: "Test"
        click_on I18n.translate("controllers.contact.govuk.service_feedback.send_feedback")
      end
      expect(page).to have_content "Thank you for contacting GOV.UK"
    end

    it "displays validation error when Service Satisfaction Rating is blank" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/some-transaction")
      within(".service-feedback") do
        fill_in I18n.translate("controllers.contact.govuk.service_feedback.how_improve"), with: "Test"
        click_on I18n.translate("controllers.contact.govuk.service_feedback.send_feedback")
      end
      expect(page).to have_content "Service satisfaction rating: You must select a rating"
    end

    it "displays validation error when Service Improvement comments exceeds maximum character count" do
      long_comment = "a" * 1255
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/some-transaction")
      within(".service-feedback") do
        choose I18n.translate("controllers.contact.govuk.service_feedback.very_satisfied")
        fill_in I18n.translate("controllers.contact.govuk.service_feedback.how_improve"), with: long_comment
        click_on I18n.translate("controllers.contact.govuk.service_feedback.send_feedback")
      end

      expect(page).to have_content "Improvement comments: The message field can be max 1250 characters"
    end
  end

  context "posting data to the Support API" do
    it "should pass the feedback through the support-api" do
      stub_post = stub_support_api_service_feedback_creation(
        service_satisfaction_rating: 5,
        details: "the transaction is ace",
        slug: "some-transaction",
        user_agent: nil,
        javascript_enabled: false,
        referrer: "https://www.some-transaction.service.gov/uk/completed",
        path: "/done/some-transaction",
        url: "https://www.gov.uk/done/some-transaction",
      )

      submit_service_feedback

      expect(response).to redirect_to(contact_anonymous_feedback_thankyou_path)
      get contact_anonymous_feedback_thankyou_path

      expect(response.body).to include("Thank you for contacting GOV.UK")
      assert_requested(stub_post)
    end

    it "should include the user_agent if available" do
      stub_support_api_service_feedback_creation

      submit_service_feedback(headers: { "HTTP_USER_AGENT" => "Shamfari/3.14159 (Fooey)" })

      assert_requested(:post, %r{/service-feedback}) do |request|
        JSON.parse(request.body)["service_feedback"]["user_agent"] == "Shamfari/3.14159 (Fooey)"
      end
    end
  end

  context "the referrer value" do
    before do
      stub_support_api_service_feedback_creation
    end

    it "uses the value in the service_feedback params" do
      posted_params = valid_params
      posted_params[:service_feedback][:referrer] = "http://referrer.example.com/i-came-from-here"
      posted_params.delete(:referrer)
      submit_service_feedback(params: posted_params)

      assert_requested(:post, %r{/service-feedback}) do |request|
        JSON.parse(request.body)["service_feedback"]["referrer"] == "http://referrer.example.com/i-came-from-here"
      end
    end

    it "uses the value in the posted params" do
      posted_params = valid_params
      posted_params[:service_feedback].delete(:referrer)
      posted_params[:referrer] = "http://referrer.example.com/i-came-from-here"
      submit_service_feedback(params: posted_params)

      assert_requested(:post, %r{/service-feedback}) do |request|
        JSON.parse(request.body)["service_feedback"]["referrer"] == "http://referrer.example.com/i-came-from-here"
      end
    end

    it "uses the value in the request headers params" do
      posted_params = valid_params
      posted_params[:service_feedback].delete(:referrer)
      posted_params.delete(:referrer)
      submit_service_feedback(params: posted_params, headers: { "HTTP_REFERER" => "http://referrer.example.com/i-came-from-here" })

      assert_requested(:post, %r{/service-feedback}) do |request|
        JSON.parse(request.body)["service_feedback"]["referrer"] == "http://referrer.example.com/i-came-from-here"
      end
    end

    it "prefers the value in the service_feedback params if all options are present" do
      posted_params = valid_params
      posted_params[:service_feedback][:referrer] = "http://referrer.example.com/i-came-from-here"
      posted_params[:referrer] = "http://referrer.example.com/i-did-not-come-from-here"
      submit_service_feedback(params: posted_params, headers: { "HTTP_REFERER" => "http://referrer.example.com/i-did-not-come-from-here-either" })

      assert_requested(:post, %r{/service-feedback}) do |request|
        JSON.parse(request.body)["service_feedback"]["referrer"] == "http://referrer.example.com/i-came-from-here"
      end
    end
  end

  it "should handle the support-api being unavailable" do
    stub_support_api_isnt_available

    submit_service_feedback

    # the user should see the standard GOV.UK 503 page
    expect(response.code).to eq("503")
  end

  def submit_service_feedback(params: valid_params, headers: {})
    post "/done/some-transaction", params:, headers:
  end

  def valid_params
    {
      service_feedback: {
        service_satisfaction_rating: "5",
        improvement_comments: "the transaction is ace",
        slug: "some-transaction",
        url: "https://www.gov.uk/done/some-transaction",
        referrer: "https://www.some-transaction.service.gov/uk/completed",
      },
    }
  end

  def format
    "completed_transaction"
  end

  def slug
    "done/some-transaction"
  end
end
