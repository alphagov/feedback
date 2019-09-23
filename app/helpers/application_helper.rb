require "uri"

module ApplicationHelper
  def external_link?(url)
    URI(url).host && URI(url).host != "www.gov.uk"
  end
end
