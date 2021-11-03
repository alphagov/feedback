require "gds_api/publishing_api"

class Contact::Govuk::AccessibleFormatRequestsController < ContactController
  rescue_from UnfoundAttachmentError, with: :unable_to_create_ticket_error
  rescue_from NotifyService::Error, with: :unable_to_create_ticket_error
  helper_method :question_title, :question_caption, :question_inputs, :content_base_path, :content_title, :last_question?, :next_question_number, :submission_path, :permitted_params
  before_action :show_previous_with_errors_if_missing_input
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

    if format_request.valid? && format_request.save
      render "contact/govuk/accessible_format_requests/sent"
    else
      render "contact/govuk/accessible_format_requests/error"
    end
  end

protected

  def unable_to_create_ticket_error(exception)
    log_exception(exception)

    render "contact/govuk/accessible_format_requests/error"
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

  def question_title
    presented_question[:title]
  end

  def question_caption
    presented_question[:caption]
  end

  def question_inputs
    presented_question[:inputs]
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
    params.permit(*question_keys, *document_params, :question_number)
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

  def content_title
    content_item["title"]
  end

  def content_attachments
    content_item.dig("details", "attachments")
  end

  def requested_attachment
    @requested_attachment ||= content_attachments.find { |a| a["id"] == params[:attachment_id] }

    if @requested_attachment.blank?
      raise UnfoundAttachmentError, "content_id: #{params[:content_id]}, attachent_id: #{params[:attachment_id]}"
    end

    @requested_attachment
  end

  def requested_document_title
    requested_attachment["title"]
  end

  def alternative_format_email
    requested_attachment["alternative_format_contact_email"]
  end

  def show_previous_with_errors_if_missing_input
    return unless params[:previous_question_number]

    previous_question = questions[(params[:previous_question_number].to_i - 1)]

    input_errors = previous_question["inputs"].each_with_object({}) do |input, errors|
      key = input["key"]
      error_message = input["error_message"]
      if params[key].blank? && error_message
        errors[key] = error_message
      end
    end

    if input_errors.any?
      flash[:input_errors] = input_errors
      redirect_post(request.original_url, params: permitted_params.to_h.merge(question_number: params[:previous_question_number]))
    end
  end
end
