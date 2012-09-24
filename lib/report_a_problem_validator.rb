require 'base_validator'

class ReportAProblemValidator < BaseValidator

  def initialize(params)
    super params
  end

  def validate
    validate_existence :what_wrong
    validate_existence :what_doing
    validate_max_length :what_wrong
    validate_max_length :what_doing
    errors
  end
end
