require 'rails_helper'

RSpec.describe EmailSurveySignup, type: :model do
  include ActiveSupport::Testing::TimeHelpers

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

  subject(:email_survey_signup) { described_class.new(survey_options) }
  let(:survey_options) do
    {
      survey_id: 'education_email_survey',
      survey_source: 'https://www.gov.uk/done/some-transaction',
      email_address: 'i_like_taking_surveys@example.com'
    }
  end

  context "a minimal valid email survey signup item" do
    it { is_expected.to be_valid }

    context '#save' do
      it 'sends an email to the email address using GOV.UK notify' do
        expect(Feedback.survey_notify_service).to receive(:send_email).with(subject)
        subject.save
      end

      it "should raise an exception if the GOV.UK notify call doesn't work" do
        allow(Feedback.survey_notify_service).to receive(:send_email).and_raise(SurveyNotifyService::Error.new("uh-oh!"))
        expect { subject.save }.to raise_error(SurveyNotifyService::Error, "uh-oh!")
      end
    end
  end

  context 'an invalid feedback item' do
    let(:survey_options) { {} }

    context '#save' do
      it 'does not send an email using GOV.UK notify' do
        expect(Feedback.survey_notify_service).not_to receive(:send_email)
        subject.save
      end
    end
  end

  context 'validations' do
    it { is_expected.not_to allow_value(nil).for(:survey_id) }
    it { is_expected.to validate_inclusion_of(:survey_id).in_array(EmailSurvey.all.map(&:id)) }
    it 'is invalid if the survey_id refers to a survey that has not started yet' do
      the_past = education_email_survey.start_time - 1.minute
      travel_to(the_past) do
        expect(subject).not_to be_valid
      end
    end
    it 'is valid if the survey_id refers to a survey that has started and has not expired' do
      the_now = education_email_survey.end_time - 1.minute
      travel_to(the_now) do
        expect(subject).to be_valid
      end
    end
    it 'is invalid if the survey_id refers to a sruvey that has expired' do
      the_future = education_email_survey.end_time + 1.minute
      travel_to(the_future) do
        expect(subject).not_to be_valid
      end
    end

    it { is_expected.not_to allow_value(nil).for(:survey_source) }
    it 'ensures `survey_source` has a length of at most 2048' do
      # at the boundary it's ok
      subject.survey_source = 'https://www.gov.uk/' + ('a' * 2029)
      subject.valid?
      expect(subject.errors[:survey_source]).not_to include "is too long (maximum is 2048 characters)"

      # one char over and it errors
      subject.survey_source += 'a'
      subject.valid?
      expect(subject.errors[:survey_source]).to include "is too long (maximum is 2048 characters)"
    end
    it "filters 'survey_source' to either nil or a valid URL" do
      subject.survey_source = 'https://www.gov.uk'
      expect(subject.survey_source).to eq('https://www.gov.uk')

      subject.survey_source = "http://bla.example.org:9292/méh/fào?bar"
      expect(subject.survey_source).to be_nil

      subject.survey_source = nil
      expect(subject.survey_source).to be_nil
    end
    it "adds the website root to relative sources" do
      subject.survey_source = '/relative/url'
      expect(subject.survey_source).to eq("#{Plek.new.website_root}/relative/url")
    end

    it { is_expected.not_to allow_value(nil).for(:email_address) }
    it { is_expected.not_to allow_value("this15n0+A|\\|email").for(:email_address) }
    it { is_expected.not_to allow_value("abc @d.com").for(:email_address) }
    it { is_expected.not_to allow_value("abc@d.com.").for(:email_address) }
    it { is_expected.to validate_length_of(:email_address).is_at_most(1250) }
  end

  context "#spam?" do
    it 'is not spam' do
      expect(subject).not_to be_spam
    end
  end

  context "#survey_name" do
    it 'is the name of the survey instance' do
      expect(subject.survey_name).to eq 'My name is: Education survey'
    end

    it 'is nil if the survey instance does not exist' do
      subject.survey_id = 'not-a-survey'
      expect(subject.survey_name).to be_nil
    end
  end

  context "#survey_url" do
    it 'is the survey_source escaped and added as a `c` querystring to the url of the survey instance' do
      expect(subject.survey_url).to eq 'http://survey.example.com/1?c=https%3A%2F%2Fwww.gov.uk%2Fdone%2Fsome-transaction'
    end

    it 'adds the `c` param properly if the survey url already has a querystring' do
      education_email_survey.url = "http://survey.example.com/1?foo=bar"
      expect(subject.survey_url).to eq 'http://survey.example.com/1?foo=bar&c=https%3A%2F%2Fwww.gov.uk%2Fdone%2Fsome-transaction'
    end

    it 'encodes querystrings in the survey_source correctly' do
      subject.survey_source = 'https://www.gov.uk/done/some-transaction?foo=bar&baz=qux'
      expect(subject.survey_url).to eq 'http://survey.example.com/1?c=https%3A%2F%2Fwww.gov.uk%2Fdone%2Fsome-transaction%3Ffoo%3Dbar%26baz%3Dqux'
    end

    it 'is nil if the survey instance does not exist' do
      subject.survey_id = 'not-a-survey'
      expect(subject.survey_url).to be_nil
    end
  end

  context "#to_notify_params" do
    subject { email_survey_signup.to_notify_params }

    it "includes the default template_id" do
      expect(subject[:template_id]).to eq '8fe8ab4f-a6ac-44a1-9d8b-f611a493231b'
    end

    it "includes the email address" do
      expect(subject[:email_address]).to eq 'i_like_taking_surveys@example.com'
    end

    it "includes a reference to uniquely connect the signup to the notification" do
      expect(subject[:reference]).to eq "email-survey-signup-#{email_survey_signup.object_id}"
    end

    it "includes the survey name in the personalisation details" do
      expect(subject[:personalisation][:survey_name]).to eq 'My name is: Education survey'
    end

    it "includes the survey url in the personalisation details" do
      expect(subject[:personalisation][:survey_url]).to eq 'http://survey.example.com/1?c=https%3A%2F%2Fwww.gov.uk%2Fdone%2Fsome-transaction'
    end
  end
end
