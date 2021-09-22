class Contact::Govuk::AccessibleFormatRequestsController < ContactController
  helper_method :question_component, :question_title, :question_caption, :question_inputs, :question_options, :question_key, :last_question?, :next_question_number, :permitted_params
  before_action :increment_question_number_if_optional_skipped, only: [:form]

  def form; end

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
end
