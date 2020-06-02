require File.expand_path("boot", __dir__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

Bundler.require(*Rails.groups)

module Feedback
  class Application < Rails::Application
    config.load_defaults 5.1

    config.action_dispatch.rack_cache = nil

    config.active_support.escape_html_entities_in_json = true

    config.assets.enabled = true
    config.assets.precompile += %w[application-ie6.css]
    config.assets.prefix = "/assets/feedback"
    config.assets.version = "1.0"

    # allow overriding the asset host with an enironment variable, useful for
    # when router is proxying to this app but asset proxying isn't set up.
    config.asset_host = ENV["ASSET_HOST"]

    config.eager_load_paths += %W[#{config.root}/lib]

    config.encoding = "utf-8"

    config.filter_parameters += %i[password name email email_confirmation textdetails what_doing what_wrong]
  end
end
