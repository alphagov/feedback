require 'base_validator'

class GeneralFeedbackValidator < BaseValidator
  def initialize(params)
    super params
  end

  def validate
    validate_user_details
    validate_existance :feedback
    validate_max_length :feedback
    errors
  end
end
