module UrlNormaliser
  def self.valid_url?(candidate, relative_only: false)
    url = URI.parse(candidate) rescue false
    if relative_only
      url.is_a?(URI::Generic) && url.relative? && candidate.starts_with?('/')
    else
      url.is_a?(URI::Generic) && (url.is_a?(URI::HTTP) || url.is_a?(URI::HTTPS) || url.relative?)
    end
  end

  def self.url_if_valid(candidate)
    if !valid_url?(candidate) then nil
    elsif URI.parse(candidate).relative? then Plek.new.website_root + candidate
    else candidate
    end
  end

  def self.relative_to_website_root(candidate)
    return if candidate.nil?
    candidate.sub(/\A#{Regexp.escape(Plek.new.website_root)}/, '')
  end
end
