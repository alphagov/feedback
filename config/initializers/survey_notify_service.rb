require 'survey_notify_service'

api_key = ENV['SURVEY_NOTIFY_SERVICE_API_KEY']
Feedback.survey_notify_service = SurveyNotifyService.new(api_key)

