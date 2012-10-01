require 'base_validator'

class ContactValidator < BaseValidator

  def initialize(params)
    super params
  end

  def validate
    validate_existence :textdetails
    validate_max_length :textdetails
    validate_max_length :name
    validate_max_length :email
    validate_email
    errors
  end
end
