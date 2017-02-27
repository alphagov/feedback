require 'rails_helper'

RSpec.describe EmailSurveySignup, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:education_email_survey) {
    EmailSurvey.new(
      id: 'education_email_survey',
      url: 'http://survey.example.com/1',
      start_time: 1.day.ago,
      end_time: 2.days.from_now
    )
  }
  let(:all_surveys) { { education_email_survey.id => education_email_survey } }
  before do
    stub_const('EmailSurvey::SURVEYS', all_surveys)
  end

  subject { described_class.new(survey_options) }
  let(:survey_options) do
    {
      survey_id: 'education_email_survey',
      survey_source: 'https://www.gov.uk/done/some-transaction',
      email_address: 'i_like_taking_surveys@example.com'
    }
  end

  context "a minimal valid email survey signup item" do
    it { is_expected.to be_valid }
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
end
