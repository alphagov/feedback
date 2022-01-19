require_relative "boot"

require "rails"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_support/time"
require "sprockets/railtie"

Bundler.require(*Rails.groups)

module Feedback
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # allow overriding the asset host with an enironment variable, useful for
    # when router is proxying to this app but asset proxying isn't set up.
    config.asset_host = ENV["ASSET_HOST"]

    # Using a sass css compressor causes a scss file to be processed twice
    # (once to build, once to compress) which breaks the usage of "unquote"
    # to use CSS that has same function names as SCSS such as max.
    # https://github.com/alphagov/govuk-frontend/issues/1350
    config.assets.css_compressor = nil

    config.max_age = ENV["MAX_AGE"] || 300
  end
end
