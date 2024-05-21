require "rails_helper"
require "notify_service"

RSpec.describe NotifyService do
  include EmailSurveyHelpers

  let(:education_email_survey) { create_education_email_survey }
  before do
    stub_surveys_data education_email_survey
  end

  before do
    stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
      .to_return(status: 200, body: "{}")
  end
end
