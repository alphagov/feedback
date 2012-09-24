require 'base_validator'

class ICantFindValidator < BaseValidator

  def initialize(params)
    super params
  end

  def validate
    validate_user_details
    validate_existence :lookingfor
    validate_max_length :searchterms
    validate_max_length :lookingfor
    errors
  end
end
