require 'base_validator'

class AskAQuestionValidator < BaseValidator
  @@required = [
    :name,
    :email,
    :verifyemail,
    :question
  ]

  class << self
    def required
      @@required
    end
    def validate_other(params)
      errors = []
      unless params[:email] =~ /^.+@.+/
        errors << 'Not a valid email address'
      end
      unless params[:email] ==  params[:verifyemail]
        errors << 'The two email addresses must match'
      end
      if params[:question].length > 1200
        errors << 'Question can be max 1200 characters'
      end
      if params[:searchterms].length > 1200
        errors << 'Question can be max 1200 characters'
      end
      errors
    end
  end
end
