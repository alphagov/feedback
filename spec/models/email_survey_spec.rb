require "rails_helper"

RSpec.describe EmailSurvey, type: :model do
  include EmailSurveyHelpers
  subject(:education_email_survey) { create_education_email_survey }
  before do
    stub_surveys_data(education_email_survey)
  end

  describe ".find" do
    subject { described_class }
    it "returns the survey with the supplied id" do
      expect(subject.find("education_email_survey")).to eq education_email_survey
    end

    it "raises a NotFoundError if the supplied id is not a real survey" do
      expect {
        subject.find("not-a-real-survey")
      }.to raise_error(described_class::NotFoundError, "not-a-real-survey")
    end
  end

  describe "#active?" do
    it "is not active when the start_time is in the future" do
      expect(subject.active?(at: 2.days.ago)).to eq(false)
    end

    it "is not active when the end_time is in the past" do
      expect(subject.active?(at: 2.days.from_now)).to eq(false)
    end

    it "is active on the start time" do
      expect(subject.active?(at: subject.start_time)).to eq(true)
    end

    it "is active on the end time" do
      expect(subject.active?(at: subject.end_time)).to eq(true)
    end

    it "is active between the start and end time" do
      expect(subject.active?(at: subject.start_time + 1.second)).to eq(true)
      expect(subject.active?(at: subject.end_time - 1.second)).to eq(true)
    end
  end
end
