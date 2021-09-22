require "rails_helper"

RSpec.describe Contact::Govuk::AccessibleFormatRequestsController, type: :controller do
  render_views

  describe "#form" do
    let(:format_request_questions) { YAML.load_file(Rails.root.join("app/lib/accessible_format_request/questions.yaml"))["questions"] }
    let(:content_id) { "123abc" }
    let(:attachment_id) { "456def" }
    let(:base_params) { { content_id: content_id, attachment_id: attachment_id } }
    let(:example_param) { "example" }

    context "on the first question" do
      it "renders the first question title" do
        post :form, params: base_params
        expect(response.body).to include(format_request_questions.first["title"])
      end
    end

    context "on the 2nd question" do
      before { post :form, params: base_params.merge({ 'question_number': "2", 'format_type': example_param }) }
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
