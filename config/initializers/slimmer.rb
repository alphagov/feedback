Feedback::Application.configure do
  config.slimmer.logger = Rails.logger

  if Rails.env.production?
    config.slimmer.use_cache = true
  end

  if Rails.env.development?
    #config.slimmer.asset_host = ENV["STATIC_DEV"] || Plek.current.find('static')
    config.slimmer.asset_host = "http://static.preview.alphagov.co.uk"
  end
end
