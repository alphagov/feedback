require 'rails_helper'
require 'survey_notify_service'

RSpec.describe SurveyNotifyService do
  let(:education_email_survey) {
    EmailSurvey.new(
      id: 'education_email_survey',
      url: 'http://survey.example.com/1',
      start_time: 1.day.ago,
      end_time: 2.days.from_now,
      name: 'My name is: Education survey'
    )
  }
  let(:all_surveys) { { education_email_survey.id => education_email_survey } }
  before do
    stub_const('EmailSurvey::SURVEYS', all_surveys)
  end
  let(:email_survey_signup) do
    EmailSurveySignup.new(
      survey_id: 'education_email_survey',
      survey_source: 'https://www.gov.uk/done/some-transaction',
      email_address: 'i_like_taking_surveys@example.com'
    )
  end

  before do
    stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
      .to_return(status: 200, body: '{}')
  end

  context '#send_email' do
    # This is not a valid key, but it has the right form
    let(:api_key) { 'testkey1-12345678-90ab-cdef-1234-567890abcdef-12345678-90ab-cdef-1234-567890abcdef' }
    subject { described_class.new(api_key) }

    it 'sends the survey signup to notify' do
      send_email_request = a_request(:post,
        'https://api.notifications.service.gov.uk/v2/notifications/email'
      ).with(body: email_survey_signup.to_notify_params.to_json)

      subject.send_email(email_survey_signup)

      expect(send_email_request).to have_been_requested
    end

    it 'wraps any errors from the notify API' do
      stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
        .to_return(status: 403, body: '{"errors":[{"error":"Forbidden","message":"You are not allowed to do this"}]}')
      expect {
        subject.send_email(email_survey_signup)
      }.to raise_error { |error|
        expect(error).to be_a described_class::Error
        expect(error.message).to match(/Communication with notify service failed/)
        expect(error.cause).to be_a Notifications::Client::RequestError
        expect(error.cause.code).to eq '403'
        expect(error.cause.message).to eq [{"error" => "Forbidden", "message" => "You are not allowed to do this"}]
      }
    end
  end
end
