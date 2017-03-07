require 'survey_notify_service'

api_key = if Rails.env.test?
  # This is not a valid key, but it has the right form so the client
  # won't break when interrogating it
  'testkey1-12345678-90ab-cdef-1234-567890abcdef-12345678-90ab-cdef-1234-567890abcdef'
else
  ENV['SURVEY_NOTIFY_SERVICE_API_KEY']
end

Feedback.survey_notify_service = SurveyNotifyService.new(api_key)

