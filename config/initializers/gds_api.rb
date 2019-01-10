require 'gds_api/base'

GdsApi::Base.default_options = {
  logger: Rails.application.config.logstasher.logger
}
