require 'spec_helper'
require 'gds_api/test_helpers/support'

describe ServiceFeedback do
  include ValidatorHelper
  include GdsApi::TestHelpers::Support

  context "valid service feedback" do  
    let(:subject) { ServiceFeedback.new(options) }
    let(:options) { { service_satisfaction_rating: "5", improvement_comments: "Could it be any more black" } }
    it { should be_valid }

    it "should raise an exception if support isn't available" do
      support_isnt_available
      lambda { subject.save }.should raise_error(GdsApi::BaseError)
    end

    its(:details) { should include(service_satisfaction_rating: 5) }
  end

  it { should_not allow_value(nil).for(:service_satisfaction_rating) }
  it { should allow_value(nil).for(:improvement_comments) }
  it { should ensure_inclusion_of(:service_satisfaction_rating).in_array(('1'..'5').to_a) }

  it { should ensure_length_of(:improvement_comments).is_at_most(Ticket::FIELD_MAXIMUM_CHARACTER_COUNT).with_long_message(/can be max 1250 characters/) }
  it { should ensure_length_of(:slug).is_at_most(512) }

  it { should ensure_length_of(:url).is_at_most(2048) }
  it { should allow_value("https://www.gov.uk/done/whatever").for(:url) }

  context "when a valid absolute URL is passed" do
    let(:subject) { ServiceFeedback.new(service_satisfaction_rating: "5", url: "https://www.gov.uk/done/whenever") }
    its(:details) { should include(url: "https://www.gov.uk/done/whenever") }
  end

  context "when a relative URL is passed (in prod)" do
    before do
      Plek.any_instance.stub(:website_root).and_return("https://www.something.gov.uk")
    end

    let(:subject) { ServiceFeedback.new(service_satisfaction_rating: "5", url: "/done/whenever") }
    its(:details) { should include(url: "https://www.something.gov.uk/done/whenever") }
  end
end
