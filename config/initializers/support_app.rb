require 'gds_api/support'
require 'gds_api/support_api'

token = ENV.fetch('SUPPORT_API_BEARER_TOKEN', 'xxxxx')
Rails.application.config.support = GdsApi::Support.new(Plek.current.find('support'), bearer_token: token)
Rails.application.config.support_api = GdsApi::SupportApi.new(Plek.current.find('support-api'))
