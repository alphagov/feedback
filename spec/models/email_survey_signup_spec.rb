require "rails_helper"

RSpec.describe EmailSurveySignup, type: :model do
  include ActiveSupport::Testing::TimeHelpers
  include EmailSurveyHelpers

  let(:education_email_survey) { create_education_email_survey }
  before do
    stub_surveys_data(education_email_survey)
  end

  subject(:email_survey_signup) { described_class.new(survey_options) }
  let(:survey_options) do
    {
      survey_id: "education_email_survey",
      survey_source: "/done/some-transaction",
      email_address: "i_like_taking_surveys@example.com",
      ga_client_id: "12345.67890",
    }
  end

  context "a minimal valid email survey signup item" do
    it { is_expected.to be_valid }

    context "#save" do
      it "sends an email to the email address using GOV.UK notify" do
        expect(Rails.application.config.survey_notify_service).to receive(:send_email).with(subject)
        subject.save
      end

      it "should raise an exception if the GOV.UK notify call doesn't work" do
        allow(Rails.application.config.survey_notify_service).to receive(:send_email).and_raise(SurveyNotifyService::Error.new("uh-oh!"))
        expect { subject.save }.to raise_error(SurveyNotifyService::Error, "uh-oh!")
      end
    end
  end

  context "an invalid feedback item" do
    let(:survey_options) { {} }

    context "#save" do
      it "does not send an email using GOV.UK notify" do
        expect(Rails.application.config.survey_notify_service).not_to receive(:send_email)
        subject.save
      end
    end
  end

  context "validations" do
    it { is_expected.not_to allow_value(nil).for(:survey_id) }
    it { is_expected.to validate_inclusion_of(:survey_id).in_array(EmailSurvey.all.map(&:id)) }
    it "is invalid if the survey_id refers to a survey that has not started yet" do
      the_past = education_email_survey.start_time - 1.minute
      travel_to(the_past) do
        expect(subject).not_to be_valid
      end
    end
    it "is valid if the survey_id refers to a survey that has started and has not expired" do
      the_now = education_email_survey.end_time - 1.minute
      travel_to(the_now) do
        expect(subject).to be_valid
      end
    end
    it "is invalid if the survey_id refers to a sruvey that has expired" do
      the_future = education_email_survey.end_time + 1.minute
      travel_to(the_future) do
        expect(subject).not_to be_valid
      end
    end

    it { is_expected.not_to allow_value(nil).for(:survey_source) }
    it "ensures `survey_source` has a length of at most 2048" do
      # at the boundary it's ok
      subject.survey_source = "/" + ("a" * 2047)
      subject.valid?
      expect(subject.errors[:survey_source]).not_to include "is too long (maximum is 2048 characters)"

      # one char over and it errors
      subject.survey_source += "a"
      subject.valid?
      expect(subject.errors[:survey_source]).to include "is too long (maximum is 2048 characters)"
    end
    it "expects 'survey_source' to be a relative url and start with a `/`" do
      subject.survey_source = "done/some-transaction"
      subject.valid?
      expect(subject.errors[:survey_source]).not_to be_empty
    end
    it "allows 'survey_source' to be a relative url with a query-string" do
      subject.survey_source = "/done/some-transaction?cachebust=1234"
      subject.valid?
      expect(subject.errors[:survey_source]).to be_empty
    end
    it "strips the domain from absolute urls that come from the website root" do
      subject.survey_source = "#{Plek.new.website_root}/absolute/url"
      subject.valid?
      expect(subject.errors[:survey_source]).to be_empty
      expect(subject.survey_source).to eq("/absolute/url")
    end
    it "leaves query-strings in the 'survey_source'" do
      subject.survey_source = "/done/some-transaction?cachebust=1234"
      expect(subject.survey_source).to eq "/done/some-transaction?cachebust=1234"
    end
    it "rejects absolute urls that come from the a different domain" do
      subject.survey_source = "https://www.example.com/absolute/url"
      subject.valid?
      expect(subject.errors[:survey_source]).not_to be_empty
    end

    it { is_expected.not_to allow_value(nil).for(:email_address) }
    it { is_expected.not_to allow_value("this15n0+A|\\|email").for(:email_address) }
    it { is_expected.not_to allow_value("abc @d.com").for(:email_address) }
    it { is_expected.not_to allow_value("abc@d.com.").for(:email_address) }
    it { is_expected.to validate_length_of(:email_address).is_at_most(1250) }

    it "adds ga_client_id to end of surveyUrl" do
      subject.ga_client_id = "12345.67890"
      subject.survey_source = "/done/some-transaction"
      expect(subject.survey_url).to include("&gcl=12345.67890")
    end

    it "doesn't add the ga_client_id if it's not provided" do
      subject.ga_client_id = nil
      subject.survey_source = "/done/some-transaction"
      expect(subject.survey_url).to_not include("&gcl")
    end
  end

  context "#spam?" do
    it "is not spam" do
      expect(subject).not_to be_spam
    end
  end

  context "#survey_name" do
    it "is the name of the survey instance" do
      expect(subject.survey_name).to eq "My name is: Education survey"
    end

    it "is nil if the survey instance does not exist" do
      subject.survey_id = "not-a-survey"
      expect(subject.survey_name).to be_nil
    end
  end

  context "#survey_url" do
    it "is the survey_source escaped and added as a `c` querystring to the url of the survey instance" do
      expect(subject.survey_url).to eq "http://survey.example.com/1?c=%2Fdone%2Fsome-transaction&gcl=12345.67890"
    end

    it "adds the `c` param properly if the survey url already has a querystring" do
      education_email_survey.url = "http://survey.example.com/1?foo=bar"
      expect(subject.survey_url).to eq "http://survey.example.com/1?foo=bar&c=%2Fdone%2Fsome-transaction&gcl=12345.67890"
    end

    it "encodes querystrings in the survey_source correctly" do
      subject.survey_source = "/done/some-transaction?foo=bar&baz=qux"
      expect(subject.survey_url).to eq "http://survey.example.com/1?c=%2Fdone%2Fsome-transaction%3Ffoo%3Dbar%26baz%3Dqux&gcl=12345.67890"
    end

    it "is nil if the survey instance does not exist" do
      subject.survey_id = "not-a-survey"
      expect(subject.survey_url).to be_nil
    end
  end

  context "#to_notify_params" do
    subject { email_survey_signup.to_notify_params }

    it "includes the default template_id" do
      expect(subject[:template_id]).to eq "8fe8ab4f-a6ac-44a1-9d8b-f611a493231b"
    end

    it "includes the email address" do
      expect(subject[:email_address]).to eq "i_like_taking_surveys@example.com"
    end

    it "includes a reference to uniquely connect the signup to the notification" do
      expect(subject[:reference]).to eq "email-survey-signup-#{email_survey_signup.object_id}"
    end

    it "only has survey_url as a key in the personalisation details" do
      # Notify raises an error if you supply un-needed params in the
      # personalisation hash and our template only uses survey_url currently
      expect(subject[:personalisation].size).to eq 1
      expect(subject[:personalisation]).to have_key(:survey_url)
    end

    it "includes the survey url in the personalisation details" do
      expect(subject[:personalisation][:survey_url]).to eq "http://survey.example.com/1?c=%2Fdone%2Fsome-transaction&gcl=12345.67890"
    end
  end
end
