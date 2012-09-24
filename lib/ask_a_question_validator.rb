require 'base_validator'

class AskAQuestionValidator < BaseValidator

  def initialize(params)
    super params
  end

  def validate
    validate_user_details
    validate_existence :question
    validate_max_length :searchterms
    validate_max_length :question
    errors
  end
end
