class Contact::Govuk::AccessibleFormatRequestsController < ContactController
  helper_method :question_component, :question_title, :question_caption, :question_inputs, :question_options, :question_key, :last_question?, :next_question_number, :permitted_params

  def form; end

private

  def questions
    @questions ||= YAML.load_file(Rails.root.join("app/lib/accessible_format_request/questions.yaml")).with_indifferent_access["questions"]
  end

  def current_question
    questions[question_number - 1]
  end

  def question_component
    question_inputs[0][:component]
  end

  def question_title
    current_question[:title]
  end

  def question_caption
    current_question[:caption]
  end

  def question_inputs
    current_question[:inputs]
  end

  def question_options
    question_inputs[0][:options]
  end

  def question_key
    question_inputs[0][:key]
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
end
