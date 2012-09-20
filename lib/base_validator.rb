class BaseValidator
  @@MAX_LENGTH = 1200
  @@LENGTH_ERROR_MESSAGE = "Can be max #{@@MAX_LENGTH} characters"
  @@BLANK_ERROR_MESSAGE = "Above field cannot be empty"

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

  def validate_max_length(field)
    unless @params[field].blank?
      if @params[field].length > @@MAX_LENGTH
        add_error field, @@LENGTH_ERROR_MESSAGE
      end
    end
  end

  def validate_existence(field)
    if @params[field].blank?
      add_error field, @@BLANK_ERROR_MESSAGE
    end
  end

  def validate_user_details
    validate_name
    validate_email
    validate_existence :email
    validate_existence :name
    validate_existence :verifyemail
  end

  def validate_email
    unless @params[:email] ==  @params[:verifyemail]
      add_error :email, 'The two email addresses must match'
    end
    unless @params[:email] =~/^[\w\d]+[^@]*@[\w\d]+[^@]*\.[\w\d]+[^@]*$/
      add_error :email, 'Invalid email address'
    end
    unless @params[:verifyemail] =~/^[\w\d]+[^@]*@[\w\d]+[^@]*\.[\w\d]+[^@]*$/
      add_error :verifyemail, 'Invalid email address'
    end
    validate_max_length :email
  end

  def validate_name
    validate_max_length :name
  end
end
