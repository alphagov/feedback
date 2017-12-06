Rails.application.configure do
  config.action_controller.asset_host = ENV['GOVUK_ASSET_HOST']
  config.action_controller.perform_caching = true

  config.action_mailer.delivery_method = :ses

  config.active_support.deprecation = :notify

  config.assets.compile = false
  config.assets.compress = true
  config.assets.digest = true

  config.cache_classes = true

  config.consider_all_requests_local = false

  config.eager_load = true

  config.i18n.fallbacks = true

  config.log_level = :info

  config.serve_static_files = false
end
