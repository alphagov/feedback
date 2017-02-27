module UrlNormaliser
  def self.valid_url?(candidate)
    url = URI.parse(candidate) rescue false
    url.is_a?(URI::Generic) && (url.is_a?(URI::HTTP) || url.is_a?(URI::HTTPS) || url.relative?)
  end

  def self.url_if_valid(candidate)
    case
    when !valid_url?(candidate) then nil
    when URI.parse(candidate).relative? then Plek.new.website_root + candidate
    else candidate
    end
  end
end
