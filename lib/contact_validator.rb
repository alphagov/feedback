require 'base_validator'

class ContactValidator < BaseValidator

  def initialize(params)
    super params
  end

  def validate
    validate_existence :textdetails
    validate_max_length :textdetails
    validate_max_length :name
    validate_email
    validate_link
    errors
  end

  def validate_link
    if (@params[:location] == "specific") and @params[:link].blank?
      add_error :link, 'Enter specific link'
    end
    validate_max_length :link
  end
end
