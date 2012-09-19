require 'base_validator'

class FoiValidator < BaseValidator
  def initialize(params)
    super params
  end

  def validate
    validate_user_details
    validate_existance :foi
    validate_max_length :foi
    errors
  end
end
