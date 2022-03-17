# Throttle by IP address and by provided email address to 1 rpm on any contact forms
# endpoint.

# Is this likely to affect the accessible request form if a lot of errors?

Rack::Attack.cache.store = Redis.new(url: ENV["REDIS_URL"]) if ENV["REDIS_URL"]

RATE_LIMIT_COUNT = ENV["RATE_LIMIT_COUNT"]&.to_i || 1
RATE_LIMIT_PERIOD = (ENV["RATE_LIMIT_PERIOD_SECONDS"]&.to_i || 60).seconds

if ENV["DISABLE_THROTTLE"]&.downcase != "true"
  Rack::Attack.throttle("requests by ip", limit: RATE_LIMIT_COUNT, period: RATE_LIMIT_PERIOD) do |request|
    Rails.logger.info("Rack::Attack: Rate-Limit-Header value: [#{request.env['HTTP_RATE_LIMIT_HEADER']}]")
    if request.path.start_with?("/contact/govuk") && request.post?
      request.ip
    end
  end

  Rack::Attack.throttle("non-anonymous requests by email address", limit: RATE_LIMIT_COUNT, period: RATE_LIMIT_PERIOD) do |request|
    normalised_email(request) if request.path.start_with?("/contact/govuk") && request.post? && has_email?(request)
  end
end

# accessible format request uses email_address, problem form uses contact{email}, so we have to check for both

def has_email?(request)
  request.params.key?("email_address") ||
    (request.params.key?("contact") && request.params["contact"].key?("email"))
end

def normalised_email(request)
  email = request.params["email_address"] || request.params.dig("contact", "email")
  email.to_s.downcase.gsub(/\s+/, "")
end
