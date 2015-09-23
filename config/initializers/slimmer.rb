Feedback::Application.configure do
  config.slimmer.logger = Rails.logger

  config.slimmer.use_cache = true if Rails.env.production?

  if Rails.env.development?
    config.slimmer.asset_host = ENV["STATIC_DEV"] || Plek.current.find('static')
  end
end
