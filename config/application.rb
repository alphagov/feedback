require File.expand_path('../boot', __FILE__)

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
    config.assets.precompile += %w(feedback.js feedback.css feedback-ie6.css)
    config.assets.prefix = '/feedback' # this has to match the path configured in puppet and deploy scripts.
    config.assets.version = '1.0'

    config.eager_load_paths += %W(#{config.root}/lib)

    config.encoding = "utf-8"

    config.filter_parameters += [:password, :name, :email, :email_confirmation, :textdetails, :what_doing, :what_wrong]
  end
end
