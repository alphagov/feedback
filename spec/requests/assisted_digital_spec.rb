require "rails_helper"
require "gds_api/test_helpers/support_api"
require "gds_api/test_helpers/content_store"

RSpec.describe "Assisted digital help with fees submission", type: :request do
  include GdsApi::TestHelpers::SupportApi
  include ActiveSupport::Testing::TimeHelpers
  include GdsApi::TestHelpers::ContentStore

  let(:payload) do
    {
      base_path: "/done/register-flood-risk-exemption",
      schema_name: "completed_transaction",
      document_type: "completed_transaction",
      external_related_links: [],
      title: "Some Transaction",
    }
  end

  before do
    stub_content_store_has_item("/#{slug}", schema_name: format)
    stub_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/*})
    stub_support_api_service_feedback_creation
    # Set auth to nil, and this won't try to incur extra requests
    allow(GoogleCredentials).to receive(:authorization).and_return nil
  end

  context "render an Assisted Digital Feedback form" do
    it "displays title from the completed transaction's content item" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")

      expect(page).to have_content("Some Transaction")
    end

    # Runs specs in support/service_feedback.rb
    include_examples "Service Feedback", "/done/register-flood-risk-exemption"

    it "displays did you receive assistance radio buttons" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")

      expect(page).to have_field("Yes", type: "radio")
      expect(page).to have_field("No", type: "radio")
    end

    it "displays service satisfaction rating radio buttons" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")

      expect(page).to have_content(I18n.translate("controllers.contact.govuk.assisted_digital_feedback.online_satisfaction_check"))
      expect(page).to have_field("service-satisfaction-rating-0", type: "radio")
      expect(page).to have_field("service-satisfaction-rating-1", type: "radio")
      expect(page).to have_field("service-satisfaction-rating-2", type: "radio")
      expect(page).to have_field("service-satisfaction-rating-3", type: "radio")
      expect(page).to have_field("service-satisfaction-rating-4", type: "radio")
    end

    it "displays service feedback improvement comments text area" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")
      expect(page).to have_field(I18n.translate("controllers.contact.govuk.assisted_digital_feedback.how_improve", type: "textarea"))
      expect(page).to have_content(I18n.translate("controllers.contact.govuk.assisted_digital_feedback.no_pii_hint"))
    end

    it "displays What assistance did you receive? text area" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")

      expect(page).to have_field(I18n.translate("controllers.contact.govuk.assisted_digital_feedback.what_assistance"), type: "textarea")
    end

    it "displays Who provided the assistance? radio buttons" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")

      expect(page).to have_content(I18n.translate("controllers.contact.govuk.assisted_digital_feedback.who_assisted"))
      expect(page).to have_field(I18n.translate("controllers.contact.govuk.assisted_digital_feedback.friend_or_relative"), type: "radio")
      expect(page).to have_field(I18n.translate("controllers.contact.govuk.assisted_digital_feedback.work_colleague"), type: "radio")
      expect(page).to have_field(I18n.translate("controllers.contact.govuk.assisted_digital_feedback.government_staff"), type: "radio")
      expect(page).to have_field(I18n.translate("controllers.contact.govuk.assisted_digital_feedback.other"), type: "radio")
    end

    it "displays How satisfied are you with the assistance received? (government staff) radio buttons" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")

      expect(page).to have_content(I18n.translate("controllers.contact.govuk.assisted_digital_feedback.satisfaction_check"))

      expect(page).to have_field("government-staff-0", type: "radio")
      expect(page).to have_field("government-staff-1", type: "radio")
      expect(page).to have_field("government-staff-2", type: "radio")
      expect(page).to have_field("government-staff-3", type: "radio")
      expect(page).to have_field("government-staff-4", type: "radio")
    end

    it "displays how could we improve this service? (government staff) text area" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")

      expect(page).to have_field("service_feedback[assistance_improvement_comments]", type: "textarea")
    end

    it "displays tell us who the other person was? (other) text input" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")

      expect(page).to have_field(I18n.translate("controllers.contact.govuk.assisted_digital_feedback.other_person"), type: "text")
    end

    it "displays How satisfied are you with the assistance received? (other) radio buttons" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")

      expect(page).to have_content(I18n.translate("controllers.contact.govuk.assisted_digital_feedback.satisfaction_check"))
      expect(page).to have_field("other-0", type: "radio")
      expect(page).to have_field("other-1", type: "radio")
      expect(page).to have_field("other-2", type: "radio")
      expect(page).to have_field("other-3", type: "radio")
      expect(page).to have_field("other-4", type: "radio")
    end

    it "displays how could we improve this service? (other) text area" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")

      expect(page).to have_field("service_feedback[assistance_improvement_comments_other]", type: "textarea")
    end

    it "displays Welsh translation when locale is set to cy" do
      payload.merge!({ locale: "cy" })
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")

      expect(page).to have_content "Helpwch ni i wella'r gwasanaeth hwn"
    end
  end

  context "form submission" do
    before do
      stub_support_api_service_feedback_creation(
        service_satisfaction_rating: 5,
        details: "Test",
        slug: "/done/register-flood-risk-exemption",
        user_agent: nil,
        javascript_enabled: false,
        referrer: "https://www.some-transaction.service.gov/uk/completed",
        path: "/done/register-flood-risk-exemption",
        url: "https://www.gov.uk/done/some-transaction",
      )
    end

    it "submits with valid data" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")
      choose("service_feedback[assistance_received]", option: "no")
      choose("service_feedback[service_satisfaction_rating]", option: "5")
      fill_in "service_feedback[assistance_improvement_comments]", with: "Test"
      click_on I18n.translate("controllers.contact.govuk.assisted_digital_feedback.send_feedback")

      expect(page).to have_content "Thank you for contacting GOV.UK"
    end

    it "displays an error message when all fields are blank" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")
      click_on I18n.translate("controllers.contact.govuk.assisted_digital_feedback.send_feedback")

      expect(page).to have_content "Assistance received: You must select if you received assistance with this service"

      expect(page).to have_content "Service satisfaction rating: You must select a rating"
    end

    it "displays an error message when assistance was not needed and fields are blank" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")
      choose("service_feedback[assistance_received]", option: "no")
      click_on I18n.translate("controllers.contact.govuk.assisted_digital_feedback.send_feedback")

      expect(page).to have_content "Service satisfaction rating: You must select a rating"
    end

    it "displays an error message when assistance was not needed and How could we improve this service is too long" do
      long_comment = "a" * 1255
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")
      within(".service-feedback") do
        choose("service_feedback[assistance_received]", option: "no")
        choose("service_feedback[service_satisfaction_rating]", option: "5")
        fill_in "service_feedback[improvement_comments]", with: long_comment
        click_on I18n.translate("controllers.contact.govuk.assisted_digital_feedback.send_feedback")
      end

      expect(page).to have_content "Improvement comments: The message field can be max 1250 characters"
    end

    it "displays an error message when assistance was needed and fields are blank" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")
      within(".service-feedback") do
        choose("service_feedback[assistance_received]", option: "yes")

        click_on I18n.translate("controllers.contact.govuk.assisted_digital_feedback.send_feedback")
      end

      expect(page).to have_content "Assistance received comments: Can't be blank"
      expect(page).to have_content "Assistance provided by: Can't be blank"
      expect(page).to have_content "Service satisfaction rating: You must select a rating"
    end

    it "displays an error message when assistance was needed and What assistance did you receive? is too long" do
      long_comment = "a" * 1255
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")
      within(".service-feedback") do
        choose("service_feedback[assistance_received]", option: "yes")
        fill_in "service_feedback[assistance_received_comments]", with: long_comment
        click_on I18n.translate("controllers.contact.govuk.assisted_digital_feedback.send_feedback")
      end

      expect(page).to have_content "Assistance received comments: The message field can be max 1250 characters"
    end

    it "displays an error message when assistance was provided by government staff and the government staff section is blank" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")
      within(".service-feedback") do
        choose("service_feedback[assistance_received]", option: "yes")
        fill_in "service_feedback[assistance_received_comments]", with: "Help with the service"
        choose("service_feedback[assistance_provided_by]", option: "government-staff")

        click_on I18n.translate("controllers.contact.govuk.assisted_digital_feedback.send_feedback")
      end

      expect(page).to have_content "Assistance satisfaction rating: You must select a rating"
    end

    it "displays an error message when assistance was provided by government staff and how could we improve this service? is too long" do
      long_comment = "a" * 1255
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")
      within(".service-feedback") do
        choose("service_feedback[assistance_received]", option: "yes")
        fill_in "service_feedback[assistance_improvement_comments]", with: long_comment
        choose("service_feedback[assistance_provided_by]", option: "government-staff")

        click_on I18n.translate("controllers.contact.govuk.assisted_digital_feedback.send_feedback")
      end

      expect(page).to have_content "Assistance improvement comments: The message field can be max 1250 characters"
    end

    it "displays an error message when assistance was provided by other and fields are blank" do
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")
      within(".service-feedback") do
        choose("service_feedback[assistance_received]", option: "yes")
        fill_in "service_feedback[assistance_received_comments]", with: "Help with the service"
        choose("service_feedback[assistance_provided_by]", option: "other")

        click_on I18n.translate("controllers.contact.govuk.assisted_digital_feedback.send_feedback")
      end

      expect(page).to have_content "Assistance provided by other: Can't be blank"
      expect(page).to have_content "Assistance satisfaction rating other: You must select a rating"
    end

    it "displays an error message when assistance was provided by other and How could we improve this service? is too long" do
      long_comment = "a" * 1255
      stub_content_store_has_item("/#{slug}", payload)
      visit("/done/register-flood-risk-exemption")
      within(".service-feedback") do
        choose("service_feedback[assistance_received]", option: "yes")
        choose("service_feedback[assistance_provided_by]", option: "other")
        fill_in "service_feedback[assistance_improvement_comments_other]", with: long_comment

        click_on I18n.translate("controllers.contact.govuk.assisted_digital_feedback.send_feedback")
      end

      expect(page).to have_content "Assistance improvement comments other: The message field can be max 1250 characters"
    end
  end

  it "shows the standard thank you message on success" do
    submit_service_feedback

    expect(response).to redirect_to(contact_anonymous_feedback_thankyou_path)
    get contact_anonymous_feedback_thankyou_path

    expect(response.body).to include("Thank you for contacting GOV.UK")
  end

  it "sends the full assisted digital feedback data to google" do
    the_past = 13.years.ago.change(usec: 0)
    travel_to(the_past) do
      submit_service_feedback

      expect(a_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/*}).with do |request|
        values = JSON.parse(request.body)["values"][0]
        values == [
          "yes",
          "someone helped me",
          "friend-relative",
          nil,
          nil,
          nil,
          5,
          "it was fine",
          "some-transaction",
          nil,
          false,
          "https://www.some-transaction.service.gov/uk/completed",
          "/done/some-transaction",
          "https://www.gov.uk/done/some-transaction",
          the_past.iso8601(3),
        ]
      end).to have_been_requested
    end
  end

  it "sends a subset of the data to the support api as service feedback" do
    service_feedback_request = stub_support_api_service_feedback_creation(
      service_satisfaction_rating: 5,
      details: "it was fine",
      slug: "some-transaction",
      user_agent: nil,
      javascript_enabled: false,
      referrer: "https://www.some-transaction.service.gov/uk/completed",
      path: "/done/some-transaction",
      url: "https://www.gov.uk/done/some-transaction",
    )
    submit_service_feedback

    expect(service_feedback_request).to have_been_requested
  end

  context "the referrer value" do
    before do
      stub_support_api_service_feedback_creation
    end

    it "uses the referrer from the posted params" do
      posted_params = valid_params
      posted_params[:referrer] = "http://referrer.example.com/i-came-from-here"
      posted_params[:service_feedback].delete(:referrer)
      submit_service_feedback(params: posted_params)

      expect(a_request(:post, %r{/service-feedback}).with do |request|
        JSON.parse(request.body)["service_feedback"]["referrer"] == "http://referrer.example.com/i-came-from-here"
      end).to have_been_requested
    end

    it "uses the referrer from the service_feedback params" do
      posted_params = valid_params
      posted_params.delete(:referrer)
      posted_params[:service_feedback][:referrer] = "http://referrer.example.com/i-came-from-here"
      submit_service_feedback(params: posted_params)

      expect(a_request(:post, %r{/service-feedback}).with do |request|
        JSON.parse(request.body)["service_feedback"]["referrer"] == "http://referrer.example.com/i-came-from-here"
      end).to have_been_requested
    end

    it "uses the referrer from the request header" do
      posted_params = valid_params
      posted_params.delete(:referrer)
      posted_params[:service_feedback].delete(:referrer)
      submit_service_feedback(params: posted_params, headers: { "HTTP_REFERER" => "http://referrer.example.com/i-came-from-here" })

      expect(a_request(:post, %r{/service-feedback}).with do |request|
        JSON.parse(request.body)["service_feedback"]["referrer"] == "http://referrer.example.com/i-came-from-here"
      end).to have_been_requested
    end

    it "prefers the referrer from the service_feedback params if all are present header" do
      posted_params = valid_params
      posted_params[:referrer] = "http://referrer.example.com/i-did-not-come-from-here"
      posted_params[:service_feedback][:referrer] = "http://referrer.example.com/i-came-from-here"
      submit_service_feedback(params: posted_params, headers: { "HTTP_REFERER" => "http://referrer.example.com/i-did-not-come-from-here-either" })

      expect(a_request(:post, %r{/service-feedback}).with do |request|
        JSON.parse(request.body)["service_feedback"]["referrer"] == "http://referrer.example.com/i-came-from-here"
      end).to have_been_requested
    end
  end

  it "should include the user_agent if available" do
    submit_service_feedback(headers: { "HTTP_USER_AGENT" => "Shamfari/3.14159 (Fooey)" })

    expect(a_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/*}).with do |request|
      JSON.parse(request.body)["values"][0][9] == "Shamfari/3.14159 (Fooey)"
    end).to have_been_requested
  end

  it "should handle the google storage service failing" do
    stub_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/*}).to_return(status: 403)

    submit_service_feedback

    # the user should see the standard GOV.UK 503 page
    expect(response.code).to eq("503")
  end

  def submit_service_feedback(params: valid_params, headers: {})
    post "/done/register-flood-risk-exemption", params:, headers:
  end

  def valid_params
    {
      service_feedback: {
        assistance_received: "yes",
        assistance_received_comments: "someone helped me",
        assistance_provided_by: "friend-relative",
        service_satisfaction_rating: "5",
        improvement_comments: "it was fine",
        slug: "some-transaction",
        url: "https://www.gov.uk/done/some-transaction",
      },
      referrer: "https://www.some-transaction.service.gov/uk/completed",
    }
  end

  def format
    "completed_transaction"
  end

  def slug
    "done/register-flood-risk-exemption"
  end
end
