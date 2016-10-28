require 'rails_helper'

RSpec.describe AssistedDigitalHelpWithFeesFeedback, type: :model do
  include ValidatorHelper

  context "a valid feedback item" do
    subject { described_class.new(options) }
    let(:options) do
      {
        assistance: 'no',
        service_satisfaction_rating: "5",
        improvement_comments: "Could it be any more black",
        slug: "some-transaction",
        url: "https://www.gov.uk/done/some-transaction",
        referrer: "https://www.some-transaction.service.gov/uk/completed",
      }
    end

    it { is_expected.to be_valid }
  end

  context 'validations' do
    it { is_expected.not_to allow_value(nil).for(:assistance) }
    it { is_expected.to validate_inclusion_of(:assistance).in_array(%w(no some all)) }

    it { is_expected.not_to allow_value(nil).for(:service_satisfaction_rating) }
    it { is_expected.to validate_inclusion_of(:service_satisfaction_rating).in_array(('1'..'5').to_a) }

    it { is_expected.to allow_value(nil).for(:improvement_comments) }
    it { is_expected.to validate_length_of(:improvement_comments).is_at_most(Ticket::FIELD_MAXIMUM_CHARACTER_COUNT).with_long_message(/can be max 1250 characters/) }

    it { is_expected.to validate_length_of(:slug).is_at_most(512) }
  end

  describe '#options' do
    subject { described_class.new(params).options }
    let(:params) do
      {
        assistance: 'no',
        service_satisfaction_rating: "4",
        improvement_comments: "it was fine",
        slug: "some-transaction",
        url: "https://www.gov.uk/done/some-transaction",
        referrer: "https://www.some-transaction.service.gov/uk/completed",
      }
    end

    it 'exposes the improvement_comments as details' do
      expect(subject[:details]).to eq "it was fine"
      expect(subject).to_not have_key :improvement_comments
    end

    it 'exposes the slug' do
      expect(subject[:slug]).to eq "some-transaction"
    end

    it 'exposes the referrer' do
      expect(subject[:referrer]).to eq "https://www.some-transaction.service.gov/uk/completed"
    end

    it 'converts service_satisfaction_rating to an integer' do
      expect(subject[:service_satisfaction_rating]).to eq 4
    end

    it 'extracts the path from the url and exposes it as path' do
      expect(subject[:path]).to eq '/done/some-transaction'
    end

    context 'javascript_enabled' do
      context 'is provided in params' do
        let(:params) { super().merge(javascript_enabled: "1") }
        it 'exposes a true value' do
          expect(subject[:javascript_enabled]).to eq true
        end
      end

      context 'is not provided in params' do
        it 'exposes a false value' do
          expect(subject[:javascript_enabled]).to eq false
        end
      end
    end

    context "with empty comments" do
      let(:params) { super().merge(improvement_comments: "") }

      it 'exposes details as a nil value' do
        expect(subject[:details]).to be_nil
      end
    end

    context "with an invalid URL" do
      let(:params) { super().merge(url: "```") }

      it 'exposes a blank path' do
        expect(subject[:path]).to be_nil
      end

      it 'exposes a blank URL' do
        expect(subject[:url]).to be_nil
      end
    end

    context "with a relative URL" do
      let(:params) { super().merge(url: "/done/some-transaction") }

      it 'exposes an absolute URL' do
        expect(subject[:url]).to eq "#{Plek.new.website_root}/done/some-transaction"
      end
    end

    context "with an invalid referrer" do
      let(:params) { super().merge(referrer: "```") }

      it 'exposes a blank referrer' do
        expect(subject[:referrer]).to be_nil
      end
    end

    context "with a relative referrer" do
      let(:params) { super().merge(referrer: "/some-transaction/completed") }

      it 'exposes an absolute referrer' do
        expect(subject[:referrer]).to eq "#{Plek.new.website_root}/some-transaction/completed"
      end
    end

  end
end
