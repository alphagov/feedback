require "rails_helper"
require "gds_api/test_helpers/publishing_api"

RSpec.describe Contact::Govuk::AccessibleFormatRequestsController, type: :controller do
  include GdsApi::TestHelpers::PublishingApi
  render_views

  let(:base_params) { { content_id: "123abc", attachment_id: "456def" } }
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
      get :format_type, params: base_params

      expect(response.body).to include("Braille")
    end

    context "without a content_id" do
      it "shows the missing content page" do
        get :format_type, params: { attachment_id: "123" }

        expect(response.body).to include("find the document you're looking for")
      end
    end

    context "without an attachemnt_id" do
      it "shows the missing content page" do
        get :format_type, params: { content_id: "123" }

        expect(response.body).to include("find the document you're looking for")
      end
    end

    context "with the publishing api down" do
      before { stub_publishing_api_isnt_available }

      it "shows the content error page" do
        get :format_type, params: base_params

        expect(response.body).to include("We are unable to fulfil your request")
      end
    end

    context "with a content id that isn't found" do
      before { stub_publishing_api_does_not_have_item("123") }

      it "shows the content error page" do
        get :format_type, params: { content_id: "123", attachment_id: "456def" }

        expect(response.body).to include("We are unable to fulfil your request")
      end
    end

    context "with an attachment id that isn't found in the content" do
      it "shows the content error page" do
        get :format_type, params: { content_id: "123abc", attachment_id: "456" }

        expect(response.body).to include("We are unable to fulfil your request")
      end
    end

    context "with an error for a missing format_type" do
      it "shows the missing format type error" do
        get :format_type, params: base_params.merge(error: "format-type-missing")

        expect(response.body).to include("Select an accessible format")
      end
    end

    context "with an error for a missing other_format" do
      it "shows the missing other format error" do
        get :format_type, params: base_params.merge(format_type: "other", error: "other-format-missing")

        expect(response.body).to include("Enter the accessible format you need")
      end
    end
  end

  describe "Contact Details" do
    context "with missing format_type" do
      it "redirects to the format page with an error" do
        post :contact_details, params: base_params

        expect(response).to redirect_to(contact_govuk_request_accessible_format_path(base_params.merge(error: "format-type-missing")))
      end
    end

    context "with other format but missing other_format" do
      it "redirects to the format page with an error" do
        post :contact_details, params: base_params.merge(format_type: "other")

        expect(response).to redirect_to(contact_govuk_request_accessible_format_path(base_params.merge(format_type: "other", error: "other-format-missing")))
      end
    end

    it "shows the contact details form" do
      post :contact_details, params: { format_type: "braille" }.merge(base_params)

      expect(response.body).to include("Email address")
    end

    it "persists params from the format type action" do
      post :contact_details, params: { format_type: "other", other_format: "a bespoke format" }.merge(base_params)

      expect(response.body).to have_css("input[name=\"format_type\"][value=\"other\"]", visible: false)
    end
  end

  describe "Send request" do
    subject { post :send_request, params: { format_type: "other", other_format: "a bespoke format", email_address: "a@example.com" }.merge(base_params) }

    context "with a missing email address" do
      it "shows the missing email address error" do
        post :send_request, params: { format_type: "other", other_format: "a bespoke format" }.merge(base_params)

        expect(response.body).to include("Enter an email address")
      end
    end

    context "with an invalid email address" do
      it "shows the missing email address error" do
        post :send_request, params: { format_type: "other", other_format: "a bespoke format", email_address: "ff" }.merge(base_params)

        expect(response.body).to include("Enter a valid email address")
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
              contact_name: nil,
              contact_email: "a@example.com",
              alternative_format_email: alternative_format_contact_email,
            ),
          ).and_return(stub_format_request)
        subject
      end

      it "redirects to the sent request confirmation view" do
        expect(subject).to redirect_to(contact_govuk_request_accessible_format_request_sent_path(base_params))
      end
    end
  end

  describe "Request sent" do
    it "shows the request sent confirmation view" do
      get :request_sent, params: base_params

      expect(response.body).to include("Request sent")
    end
  end
end
