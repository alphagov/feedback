module UrlNormaliser
  def self.valid_url?(candidate, relative_only: false)
    url = begin
      URI.parse(candidate)
    rescue StandardError
      false
    end
    if relative_only
      url.is_a?(URI::Generic) && url.relative? && candidate.starts_with?("/")
    else
      url.is_a?(URI::Generic) && (url.is_a?(URI::HTTP) || url.is_a?(URI::HTTPS) || url.relative?)
    end
  end

  def self.url_if_valid(candidate)
    return unless valid_url?(candidate)

    if URI.parse(candidate).relative?
      Plek.new.website_root + candidate
    else
      candidate
    end
  end
end
