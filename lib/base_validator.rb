class BaseValidator
  MAX_LENGTH = 1200

  def initialize(params)
    @params = params
    @errors = {}
  end

  def add_error(key, value)
    @errors[key] = value
  end

  def errors
    @errors
  end

  def validate_max_length(field, message)
    unless @params[field].blank?
      if (@params[field].delete "\r").length > MAX_LENGTH
        add_error field, message
      end
    end
  end

  def validate_existence(field, message)
    if @params[field].blank?
      add_error field, message
    end
  end

  def validate_user_details
    validate_name
    validate_email_match
    validate_email
    validate_existence :email, "The email field cannot be empty"
    validate_existence :name, "The name field cannot be empty"
  end

  def validate_email
    if @params[:email] && (not @params[:email].blank?)
      unless @params[:email] =~/^[\w\d]+[^@]*@[\w\d]+[^@]*\.[\w\d]+[^@]*$/
        add_error :email, 'The email address must be valid'
      end
      validate_max_length :email, "The email field can be max 1200 characters"
    end
  end

  def validate_email_match
    unless @params[:email] == @params[:verifyemail]
      add_error :email, 'The two email addresses must match'
    end
  end

  def validate_name
    validate_max_length :name, "The name field can be max 1200 characters"
  end
end
