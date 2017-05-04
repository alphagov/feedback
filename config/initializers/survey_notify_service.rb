require 'survey_notify_service'

api_key = ENV['SURVEY_NOTIFY_SERVICE_API_KEY']
# This is not a valid key, but it has the right form so the client
# won't break when interrogating it
if Rails.env.test?
  api_key = 'testkey1-12345678-90ab-cdef-1234-567890abcdef-12345678-90ab-cdef-1234-567890abcdef'
end

Feedback.survey_notify_service = SurveyNotifyService.new(api_key)
