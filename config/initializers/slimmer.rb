Rails.application.configure do
  config.slimmer.logger = Rails.logger

  if Rails.env.development?
    config.slimmer.asset_host = ENV["STATIC_DEV"] || Plek.current.find("static")
  end
end
