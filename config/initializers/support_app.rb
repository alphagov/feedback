require 'gds_api/support'
require 'gds_api/support_api'

Feedback.support = GdsApi::Support.new(Plek.current.find('support'), bearer_token: 'xxxxx')
Feedback.support_api = GdsApi::SupportApi.new(Plek.current.find('support-api'))

SUPPORT_API_ENABLED = true
