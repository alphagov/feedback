# Throttle by IP address and by provided email address to 1 rpm on any contact forms
# endpoint except the request-accessible-format endpoints

Rack::Attack.cache.store = Redis.new(url: ENV["REDIS_URL"]) if ENV["REDIS_URL"]

RATE_LIMIT_COUNT = ENV["RATE_LIMIT_COUNT"]&.to_i || 1
RATE_LIMIT_PERIOD = (ENV["RATE_LIMIT_PERIOD_SECONDS"]&.to_i || 60).seconds

if ENV["DISABLE_THROTTLE"]&.downcase == "true"
  Rails.logger.warn("Request throttling disabled by env var")
else
  Rack::Attack.throttle("requests by ip", limit: RATE_LIMIT_COUNT, period: RATE_LIMIT_PERIOD) do |request|
    # Only need this log message once, as it'll cover both throttles.
    Rails.logger.info("Request bypassing rate limiter with token") if bypass_token?(request)
    if throttled_path?(request.path) && request.post? && !bypass_token?(request)
      request.ip
    end
  end

  Rack::Attack.throttle("non-anonymous requests by email address", limit: RATE_LIMIT_COUNT, period: RATE_LIMIT_PERIOD) do |request|
    if throttled_path?(request.path) && request.post? && has_email?(request) && !bypass_token?(request)
      normalised_email(request)
    end
  end
end

def throttled_path?(path)
  # RAF has two posts in quick succession, so exempt it for now
  return false if path.start_with?("/contact/govuk/request-accessible-format")

  path.start_with?("/contact/govuk")
end

def bypass_token?(request)
  return false if ENV["GOVUK_RATE_LIMIT_TOKEN"].blank?

  ENV["GOVUK_RATE_LIMIT_TOKEN"] == request.env["HTTP_RATE_LIMIT_TOKEN"]
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
