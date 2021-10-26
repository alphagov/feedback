require "rails_helper"
require "gds_api/test_helpers/publishing_api"

RSpec.describe Contact::Govuk::AccessibleFormatRequestsController, type: :controller do
  include GdsApi::TestHelpers::PublishingApi
  render_views

  let(:content_id) { "123abc" }
  let(:attachment_id) { "456def" }
  let(:format_type) { "Braille" }
  let(:contact_name) { "J Doe" }
  let(:contact_email) { "doe@example.com" }
  let(:content_title) { "A document with some inaccessible attachments" }
  let(:attachment_title) { "Inaccessible CSV" }
  let(:base_path) { "/government/publications/example-document" }
  let(:alternative_format_contact_email) { "format_request@example.com" }
  let(:inaccessible_attachment) do
    {
      id: attachment_id,
      url: "/government/publications/example-document/inacessible-spreadsheet",
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
            url: "/government/publications/example-document/acessible-html",
            title: "Accessible HTML",
            attachment_type: "html",
          },
          inaccessible_attachment,
        ],
      },
    }
  end

  before { stub_publishing_api_has_item(content_item) }

  describe "#form" do
    let(:format_request_questions) { YAML.load_file(Rails.root.join("app/lib/accessible_format_request/questions.yaml"))["questions"] }
    let(:content_id) { "123abc" }
    let(:attachment_id) { "456def" }
    let(:base_params) { { content_id: content_id, attachment_id: attachment_id } }
    let(:example_param) { "custom" }
    let(:optional_question) { format_request_questions.detect { |question| question["optional"] } }
    let(:trigger_value) { optional_question["trigger-value"] }
    let(:trigger_key) { optional_question["trigger-key"] }

    context "on the first question" do
      it "renders the first question title" do
        post :form, params: base_params
        expect(response.body).to include(format_request_questions.first["title"])
      end
    end

    context "on the 2nd question" do
      before { post :form, params: base_params.merge({ 'question_number': "2", "#{trigger_key}": trigger_value }) }
      it "renders the 2nd question title" do
        expect(response.body).to include(format_request_questions[1]["title"])
      end

      it "persists previous parameters as hidden inputs" do
        submitted_params = request.params.except(:controller, :action, :question_number)
        submitted_params.each do |param, value|
          expect(response.body).to have_css("input[name=\"#{param}\"][value=\"#{value}\"]", visible: false)
        end
      end

      it "increments the previous question number as a hidden input" do
        expect(response.body).to have_css("input[name=question_number][value=3]", visible: false)
      end
    end

    context "on an optional question" do
      let(:optional_question_index) { format_request_questions.find_index(optional_question) }
      let(:optional_question_number) { optional_question_index + 1 }

      describe "when the optional triggers are passed in the params" do
        before { post :form, params: base_params.merge({ 'question_number': optional_question_number, "#{trigger_key}": trigger_value }) }
        it "renders the optional question" do
          expect(response.body).to include(optional_question["title"])
        end

        it "maintains the request question_number params in the response" do
          expect(request.params["question_number"]).to eq optional_question_number.to_s
          expect(controller.params["question_number"]).to eq optional_question_number.to_s
        end
      end

      describe "when the optional trigger is not passed in the params" do
        let(:next_question_index) { optional_question_index + 1 }
        before { post :form, params: base_params.merge({ 'question_number': optional_question_number, "#{trigger_key}": "example" }) }

        it "skips the optional question and renders the next question" do
          expect(response.body).to include(format_request_questions[next_question_index]["title"])
        end

        it "increments the request question_number param in the response" do
          expect(request.params["question_number"]).to eq optional_question_number.to_s
          expect(controller.params["question_number"]).to eq (optional_question_number + 1).to_s
        end
      end
    end

    context "on the last question" do
      before { post :form, params: base_params.merge({ 'question_number': format_request_questions.length, 'format_type': example_param }) }

      it "renders the last question title" do
        expect(response.body).to include(format_request_questions.last["title"])
      end

      it "persists previous parameters as hidden inputs" do
        submitted_params = request.params.except(:controller, :action, :question_number)
        submitted_params.each do |param, value|
          expect(response.body).to have_css("input[name=\"#{param}\"][value=\"#{value}\"]", visible: false)
        end
      end
    end
  end

  describe "#sent" do
    context "with a valid accesible format request" do
      let(:stub_format_request) { double("Request", save: true, valid?: true) }

      def do_submit
        post :sent,
             params: {
               'content_id': content_id,
               'attachment_id': attachment_id,
               'format_type': format_type,
               'contact_name': contact_name,
               'contact_email': contact_email,
             }
      end

      it "initilises an AccessibleFormatRequest with data from the params and content item" do
        expect(AccessibleFormatRequest).to receive(:new)
        .with(hash_including(
                document_title: attachment_title,
                publication_path: base_path,
                format_type: format_type,
                custom_details: nil,
                contact_name: contact_name,
                contact_email: contact_email,
                alternative_format_email: alternative_format_contact_email,
              )).and_return(stub_format_request)

        do_submit
      end

      it "validates and saves the request" do
        expect(AccessibleFormatRequest).to receive(:new).and_return(stub_format_request)
        expect(stub_format_request).to receive(:valid?)
        expect(stub_format_request).to receive(:save)

        do_submit
      end

      it "renders the accessible format request sent view" do
        expect(AccessibleFormatRequest).to receive(:new).and_return(stub_format_request)
        do_submit

        expect(response).to render_template("sent")
      end

      it "renders a link to the content item" do
        expect(AccessibleFormatRequest).to receive(:new).and_return(stub_format_request)
        do_submit

        expect(response.body).to have_link(content_title, href: base_path)
      end
    end
  end
end
