require "gds_api/publishing_api"

class Contact::Govuk::AccessibleFormatRequestsController < ContactController
  helper_method :question_component, :question_title, :question_caption, :question_inputs, :question_options, :question_key, :last_question?, :next_question_number, :submission_path, :permitted_params
  before_action :increment_question_number_if_optional_skipped, only: [:form]

  def form; end

  def sent
    format_request = AccessibleFormatRequest.new(
      document_title: requested_document_title,
      publication_path: content_base_path,
      format_type: params[:format_type],
      custom_details: params[:custom_details],
      contact_name: params[:contact_name],
      contact_email: params[:contact_email],
      alternative_format_email: alternative_format_email,
    )

    format_request.save if format_request.valid?

    @content_title = content_item["title"]
    @content_base_path = content_base_path
    render "contact/govuk/accessible_format_requests/sent"
  end

private

  def questions
    @questions ||= YAML.load_file(Rails.root.join("app/lib/accessible_format_request/questions.yaml")).with_indifferent_access["questions"]
  end

  def current_question
    @current_question ||= questions[question_number - 1]
  end

  def next_question
    last_question? ? questions.last : questions[question_number]
  end

  def presented_question
    return current_question unless optional_question?

    @presented_question ||= display_optional_question? ? current_question : next_question
  end

  def question_component
    question_inputs[0][:component]
  end

  def question_title
    presented_question[:title]
  end

  def question_caption
    presented_question[:caption]
  end

  def question_inputs
    presented_question[:inputs]
  end

  def question_options
    question_inputs[0][:options]
  end

  def question_key
    question_inputs[0][:key]
  end

  def increment_question_number_if_optional_skipped
    if optional_question? && !display_optional_question?
      params[:question_number] = (params[:question_number].to_i + 1).to_s
    end
  end

  def question_number
    params[:question_number] = 1 if params[:question_number].nil?
    params[:question_number].to_i.clamp(1, questions.length)
  end

  def last_question?
    question_number == questions.length
  end

  def next_question_number
    question_number + 1
  end

  def submission_path
    last_question? ? contact_govuk_request_accessible_format_sent_path : contact_govuk_request_accessible_format_path
  end

  def permitted_params
    document_params = %i[content_id attachment_id]
    question_keys = questions.map { |q| q["inputs"].pluck(:key) }.flatten
    params.permit(*question_keys, *document_params)
  end

  def optional_question?
    current_question[:optional]
  end

  def display_optional_question?
    trigger_key = current_question[:"trigger-key"]
    trigger_value = current_question[:"trigger-value"]
    params[trigger_key] == trigger_value
  end

  def content_item
    @content_item ||= GdsApi.publishing_api.get_content(params[:content_id]).to_h
  end

  def content_base_path
    content_item["base_path"]
  end

  def content_attachments
    content_item.dig("details", "attachments")
  end

  def requested_attachment
    @requested_attachment ||= content_attachments.find { |a| a["id"] == params[:attachment_id] }
  end

  def requested_document_title
    requested_attachment["title"]
  end

  def alternative_format_email
    requested_attachment["alternative_format_contact_email"]
  end
end
