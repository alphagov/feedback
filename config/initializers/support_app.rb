require 'gds_api/support'
require 'gds_api/support_api'

support_token = ENV.fetch('SUPPORT_BEARER_TOKEN', 'xxxxx')
support_api_token = ENV.fetch('SUPPORT_API_BEARER_TOKEN', 'xxxxx')
Rails.application.config.support = GdsApi::Support.new(Plek.current.find('support'), bearer_token: support_token)
Rails.application.config.support_api = GdsApi::SupportApi.new(Plek.current.find('support-api'), bearer_token: support_api_token)
