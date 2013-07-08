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
    string.encode('UTF-16', 'UTF-8', invalid: :replace, replace: '').encode('UTF-8', 'UTF-16')
  end
end