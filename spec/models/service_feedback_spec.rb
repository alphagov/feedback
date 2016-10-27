require 'rails_helper'
require 'gds_api/test_helpers/support_api'

RSpec.describe ServiceFeedback, type: :model do
  include ValidatorHelper
  include GdsApi::TestHelpers::SupportApi

  context "valid service feedback" do
    let(:subject) { ServiceFeedback.new(options) }
    let(:options) { { service_satisfaction_rating: "5", improvement_comments: "Could it be any more black", url: "/done/abc" } }
    it { is_expected.to be_valid }

    it "should raise an exception if the support-api isn't available" do
      support_api_isnt_available
      expect { subject.save }.to raise_error(GdsApi::BaseError)
    end

    describe '#options' do
      subject { super().options }
      it { is_expected.to include(service_satisfaction_rating: 5) }
    end

    describe '#options' do
      subject { super().options }
      it { is_expected.to include(path: "/done/abc") }
    end
  end

  it { is_expected.not_to allow_value(nil).for(:service_satisfaction_rating) }
  it { is_expected.to allow_value(nil).for(:improvement_comments) }
  it { is_expected.to validate_inclusion_of(:service_satisfaction_rating).in_array(('1'..'5').to_a) }

  it { is_expected.to validate_length_of(:improvement_comments).is_at_most(Ticket::FIELD_MAXIMUM_CHARACTER_COUNT).with_long_message(/can be max 1250 characters/) }
  it { is_expected.to validate_length_of(:slug).is_at_most(512) }

  context "with empty comments" do
    let(:subject) { ServiceFeedback.new(improvement_comments: "") }

    describe '#options' do
      subject { super().options }
      it { is_expected.to include(details: nil) }
    end
  end

  context "with an invalid URL" do
    let(:subject) { ServiceFeedback.new(url: "```") }

    describe '#options' do
      subject { super().options }
      it { is_expected.to include(path: nil) }
    end
  end
end
