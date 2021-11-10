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
  let(:department_title) { "Example Department" }
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
      links: {
        primary_publishing_organisation: [
          { title: department_title },
        ],
      },
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

  describe "#unfulfilled_request" do
    it "should render the unfulfilled_request page if missing content_id" do
      get :form, params: { attachment_id: attachment_id }
      expect(response).to render_template("unfulfilled_request")
    end

    it "should render the unfulfilled_request page if missing attachment_id" do
      get :form, params: { content_id: content_id }
      expect(response).to render_template("unfulfilled_request")
    end

    it "should not render the unfulfilled_request page if content_id and attachment_id are present" do
      get :form, params: { content_id: content_id, attachment_id: attachment_id }
      expect(response).not_to render_template("unfulfilled_request")
    end
  end

  describe "#form" do
    let(:format_request_questions) { YAML.load_file(Rails.root.join("app/lib/accessible_format_request/questions.yaml"))["questions"] }
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

      it "will submit to the #form controller method" do
        expect(response.body).to have_css("form#request-accessible-format[action=\"/contact/govuk/request-accessible-format\"]")
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

      it "will submit to the #sent controller method" do
        expect(response.body).to have_css("form#request-accessible-format[action=\"/contact/govuk/request-accessible-format/sent\"]")
      end
    end

    # Questions can have a mix of required (e.g email address) and non-required (e.g name) inputs.
    # If a user submits a form without entering a required input the page should reload with all
    # existing parameters and display an error message.
    context "displaying error messages for missing user input" do
      # The required_keys are set in the following context blocks
      let(:required_inputs) { Hash[required_keys.collect { |v| [v.to_sym, example_param] }] }

      context "questions with required user inputs" do
        let(:required_input_question) { format_request_questions.detect { |question| question["inputs"][0]["error_message"] } }
        let(:required_input_question_number) { format_request_questions.find_index(required_input_question) + 1 }

        describe "when a required user input is not entered" do
          before { post :form, params: base_params.merge({ 'question_number': required_input_question_number + 1, 'previous_question_number': required_input_question_number }) }

          it "reposts a form requesting the previous question" do
            expect(response.body).to have_css("input[name=question_number][value=#{required_input_question_number}]", visible: false)
          end

          it "sets the error messages in the flash" do
            keys_and_messages = required_input_question["inputs"].collect do |input|
              { input["key"] => input["error_message"] }
            end

            keys_and_messages.each do |key, message|
              expect(flash["input_errors"][key]).to eq message
            end
          end
        end

        describe "when all required user inputs are entered" do
          let(:required_keys) { required_input_question["inputs"].filter_map { |input| input["key"] if input["error_message"] } }

          before { post :form, params: required_inputs.merge(base_params.merge({ 'question_number': required_input_question_number + 1, 'previous_question_number': required_input_question_number })) }

          it "proceeds to the next question" do
            expect(response.body).to have_css("input[name=question_number][value=#{required_input_question_number + 1}]", visible: false)
          end

          it "does not set error messages in the flash" do
            expect(flash["input_errors"]).to eq nil
          end
        end
      end

      context "questions with unrequired user inputs" do
        let(:unrequired_input_question) { format_request_questions.find { |question| question["inputs"].detect { |input| input["error_message"].nil? } } }
        let(:unrequired_input_question_number) { format_request_questions.find_index(unrequired_input_question) + 1 }
        let(:required_keys) { unrequired_input_question["inputs"].filter_map { |input| input["key"] if input["error_message"] } }

        describe "when an unrequired user input is not entered" do
          before { post :form, params: required_inputs.merge(base_params.merge({ 'question_number': unrequired_input_question_number + 1, 'previous_question_number': unrequired_input_question_number })) }

          it "proceeds to the next question" do
            expect(response.body).to have_css("input[name=question_number][value=#{unrequired_input_question_number + 1}]", visible: false)
          end

          it "does not set error messages in the flash" do
            expect(flash["input_errors"]).to eq nil
          end
        end
      end
    end
  end

  describe "#sent" do
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

    context "with a valid accesible format request" do
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

    context "with an invalid accessible format request" do
      let(:stub_invalid_format_request) do
        double("Request",
               valid?: false,
               document_title: nil,
               publication_path: nil)
      end

      it "renders the accessible format request error view" do
        expect(AccessibleFormatRequest).to receive(:new).and_return(stub_invalid_format_request)
        do_submit

        expect(response).to render_template("error")
      end
    end

    context "with a valid accessible format request that failed to save" do
      let(:stub_unsaved_format_request) do
        double("Request",
               valid?: true,
               save: false,
               document_title: content_title,
               publication_path: base_path)
      end
      it "renders the accessible format request error view" do
        expect(AccessibleFormatRequest).to receive(:new).and_return(stub_unsaved_format_request)
        do_submit

        expect(response).to render_template("error")
      end
    end

    describe "when the Notify service causes an error" do
      it "should log the error and render the error page" do
        expect(AccessibleFormatRequest).to receive(:new).and_return(stub_format_request)
        allow(stub_format_request).to receive(:save).and_raise(NotifyService::Error.new("uh oh"))
        expect(GovukError).to receive(:notify).with(NotifyService::Error)
        do_submit

        expect(response).to render_template("error")
      end
    end

    describe "when the PublishingAPI service causes an error" do
      it "should log the error and render the error page" do
        expect(AccessibleFormatRequest).to receive(:new).and_return(stub_format_request)
        allow(stub_format_request).to receive(:save).and_raise(GdsApi::BaseError)
        expect(GovukError).to receive(:notify).with(GdsApi::BaseError)
        do_submit

        expect(response).to render_template("error")
      end

      describe "when a requested attachment can not be found" do
        it "should log the error and render the error page" do
          expect(GovukError).to receive(:notify).with(UnfoundAttachmentError)

          post :sent,
               params: {
                 'content_id': content_id,
                 'attachment_id': "unfound_id",
                 'format_type': format_type,
                 'contact_name': contact_name,
                 'contact_email': contact_email,
               }

          expect(response).to render_template("error")
        end
      end
    end
  end
end
