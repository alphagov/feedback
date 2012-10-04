require 'base_validator'

class FoiValidator < BaseValidator
  def initialize(params)
    super params
  end

  def validate
    validate_user_details
    validate_existence :textdetails, "The message field cannot be empty"
    validate_max_length :textdetails, "The message field can be max 1200 characters"
    errors
  end
end
