require 'base_validator'

class ContactValidator < BaseValidator

  def initialize(params)
    super params
  end

  def validate
    validate_mail_name_connection
    validate_existence :textdetails, "The message field cannot be empty"
    validate_max_length :textdetails, "The message field can be max 1200 characters"
    validate_max_length :name, "The name field can be max 1200 characters"
    validate_email
    validate_link
    errors
  end

  def validate_mail_name_connection
    if @params[:name].blank? and not @params[:email].blank?
      add_error :name, 'The name field cannot be empty'
    end
    if @params[:email].blank? and not @params[:name].blank?
      add_error :email, 'The email field cannot be empty'
    end
  end

  def validate_link
    if (@params[:location] == "specific") and @params[:link].blank?
      add_error :link, 'The page field cannot be empty'
    end
    validate_max_length :link, "The page field can be max 1200 characters"
  end
end
