class BaseValidator
  class << self
    def validate(params)
      validate_required(params).concat validate_other(params) 
    end

    def validate_required(params)
      errors = []
      required.each do |key|
        if params[key].blank?
          errors << "#{key} is blank"
        end
      end
      errors
    end
  end
end
