require "rails_helper"
require "gds_api/test_helpers/publishing_api"

RSpec.describe "Requests for accessible formats of documents", type: :request do
  include GdsApi::TestHelpers::PublishingApi

  let(:base_params) { { content_id: "123abc", attachment_id: "456def" } }
  let(:base_param_string) { "content_id=123abc&attachment_id=456def" }
  let(:content_id) { "123abc" }
  let(:attachment_id) { "456def" }
  let(:content_title) { "A document with some inaccessible attachments" }
  let(:attachment_title) { "Inaccessible CSV" }
  let(:base_path) { "/government/publications/example-document" }
  let(:alternative_format_contact_email) { "format_request@example.com" }
  let(:inaccessible_attachment) do
    {
      id: attachment_id,
      url: "/government/publications/example-document/inaccessible-spreadsheet",
      title: attachment_title,
      accessible: false,
      alternative_format_contact_email: alternative_format_contact_email,
    }
  end

  let(:content_item) do
    {
      base_path: base_path,
      content_id: content_id,
      title: content_title,
      details: {
        attachments: [
          {
            id: "123",
            url: "/government/publications/example-document/accessible-html",
            title: "Accessible HTML",
            attachment_type: "html",
          },
          inaccessible_attachment,
        ],
      },
    }
  end

  before { stub_publishing_api_has_item(content_item) }

  describe "Format type" do
    it "shows the format type form" do
      visit("/contact/govuk/request-accessible-format?#{base_param_string}")

      expect(page).to have_content(I18n.translate("models.accessible_format_options").first[:text])
      expect(page).to have_content(I18n.translate("models.accessible_format_options").last[:text])
    end

    context "without a content_id" do
      it "shows the missing content page" do
        visit("/contact/govuk/request-accessible-format?attachment_id=123")

        # Caption not useful here, so check for part of the body
        expect(page).to have_content("to find the document you're looking for")
      end
    end

    context "without an attachment_id" do
      it "shows the missing content page" do
        visit("/contact/govuk/request-accessible-format?content_id=123")

        # Caption not useful here, so check for part of the body
        expect(page).to have_content("to find the document you're looking for")
      end
    end

    context "with the publishing api down" do
      before { stub_publishing_api_isnt_available }

      it "shows the content error page" do
        visit("/contact/govuk/request-accessible-format?#{base_param_string}")

        expect(page).to have_content(I18n.translate("controllers.contact.govuk.accessible_format_requests.content_item_error_caption"))
      end
    end

    context "with a content id that isn't found" do
      before { stub_publishing_api_does_not_have_item("123") }

      it "shows the content error page" do
        visit("/contact/govuk/request-accessible-format?content_id=123&attachment_id=456def")

        expect(page).to have_content(I18n.translate("controllers.contact.govuk.accessible_format_requests.content_item_error_caption"))
      end
    end

    context "with an attachment id that isn't found in the content" do
      it "shows the content error page" do
        visit("/contact/govuk/request-accessible-format?content_id=123abc&attachment_id=654defnotthere")

        expect(page).to have_content(I18n.translate("controllers.contact.govuk.accessible_format_requests.content_item_error_caption"))
      end
    end

    context "with an error for a missing format_type" do
      it "shows the missing format type error" do
        visit("/contact/govuk/request-accessible-format?#{base_param_string}&error=format-type-missing")

        expect(page).to have_content(I18n.translate("controllers.contact.govuk.accessible_format_requests.format_type_error"))
      end
    end

    context "with an error for a missing other_format" do
      it "shows the missing other format error" do
        visit("/contact/govuk/request-accessible-format?#{base_param_string}&error=other-format-missing")

        expect(page).to have_content(I18n.translate("controllers.contact.govuk.accessible_format_requests.other_format_error"))
      end
    end
  end

  describe "Contact Details" do
    before do
      visit "/contact/govuk/request-accessible-format?#{base_param_string}"
    end

    context "with missing format_type" do
      it "redirects to the format page with an error" do
        click_on "Continue"

        i_should_be_on contact_govuk_request_accessible_format_path(base_params.merge(error: "format-type-missing"))
      end
    end

    context "with other format but missing other_format" do
      it "redirects to the format page with an error" do
        choose "Another accessible format"
        click_on "Continue"

        i_should_be_on contact_govuk_request_accessible_format_path(base_params.merge(format_type: "other", error: "other-format-missing"))
      end
    end

    it "shows the contact details form" do
      choose "Braille"
      click_on "Continue"

      expect(page).to have_content("Email address")
    end

    it "persists params from the format type action" do
      choose "Another accessible format"
      click_on "Continue"
      fill_in "What accessible format do you need?", with: "a bespoke format"

      expect(page).to have_css("input[name=\"format_type\"][value=\"other\"]", visible: false)
    end
  end

  describe "Send request" do
    before do
      visit "/contact/govuk/request-accessible-format?#{base_param_string}"
      choose "Another accessible format"
      fill_in "What accessible format do you need?", with: "a bespoke format"
      click_on "Continue"
    end

    subject { post "/contact/govuk/request-accessible-format/send-request", params: { format_type: "other", other_format: "a bespoke format", email_address: "a@example.com" }.merge(base_params) }

    context "with a missing email address" do
      it "shows the missing email address error" do
        click_on "Continue"

        expect(page).to have_content("Enter an email address")
      end
    end

    context "with an invalid email address" do
      it "shows the missing email address error" do
        fill_in :email_address, with: "ff"
        click_on "Continue"

        expect(page).to have_content("Enter an email address in the correct format, like name@example.com")
      end
    end

    context "with a valid accessible format request" do
      let(:stub_format_request) { double("Request", save: true, valid?: true) }
      before do
        stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
          .to_return(status: 200, body: "{}")
      end

      it "initializes an AccessibleFormatRequest with data from the params and content item" do
        expect(AccessibleFormatRequest).to receive(:new)
          .with(
            hash_including(
              document_title: attachment_title,
              publication_path: base_path,
              format_type: "other",
              custom_details: "a bespoke format",
              contact_name: "",
              contact_email: "a@example.com",
              alternative_format_email: alternative_format_contact_email,
            ),
          ).and_return(stub_format_request)

        fill_in :email_address, with: "a@example.com"
        click_on "Continue"
      end

      it "redirects to the sent request confirmation view" do
        fill_in :email_address, with: "a@example.com"
        click_on "Continue"

        i_should_be_on contact_govuk_request_accessible_format_request_sent_path(base_params)
      end
    end
  end

  describe "Request sent" do
    it "shows the request sent confirmation view" do
      visit "/contact/govuk/request-accessible-format/request-sent?#{base_param_string}&skip_slimmer=1"

      expect(page).to have_content("Request sent")
    end
  end
end
