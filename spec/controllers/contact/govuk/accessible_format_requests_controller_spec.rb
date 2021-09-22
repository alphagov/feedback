require "rails_helper"

RSpec.describe Contact::Govuk::AccessibleFormatRequestsController, type: :controller do
  render_views

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
      before {  post :form, params: base_params.merge({ 'question_number': "2", "#{trigger_key}": trigger_value }) }
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
end
