module UTF8Cleaner
  def sanitised(params)
    # `dup` is used here instead of `inject` because the params could be a ActiveSupport::HashWithIndifferentAccess
    sanitised_params = params.dup
    sanitised_params.each_key {|key| sanitised_params[key] = sanitise(sanitised_params[key])}
  end

  def sanitise(string)
    return string unless string.is_a? String

    # Try it as UTF-8 directly
    cleaned = string.dup.force_encoding('UTF-8')
    if cleaned.valid_encoding?
      cleaned
    else
      utf8clean(string)
    end
  rescue EncodingError
    utf8clean(string)
  end

  private
  def utf8clean(string)
    # Force it to UTF-8, throwing out invalid bits
    if RUBY_VERSION >= "1.9.3"
      # These converters don't exist in 1.9.2
      string.encode('UTF-16', 'UTF-8', invalid: :replace, replace: '').encode('UTF-8', 'UTF-16')
    else
      string.chars.select{|i| i.valid_encoding?}.join
    end
  end
end