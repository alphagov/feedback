require 'rails_helper'

RSpec.describe AssistedDigitalHelpWithFeesFeedback, type: :model do
  include ValidatorHelper
  include ActiveSupport::Testing::TimeHelpers

  context "a minimal valid feedback item" do
    subject { described_class.new(options) }
    let(:options) do
      {
        assistance_received: 'no',
        service_satisfaction_rating: "5",
        improvement_comments: "Could it be any more black",
        slug: "some-transaction",
        url: "https://www.gov.uk/done/some-transaction",
        referrer: "https://www.some-transaction.service.gov/uk/completed",
      }
    end

    it { is_expected.to be_valid }

    context '#save' do
      it 'sends the item to be stored in the google spreadsheet as row data' do
        expect(Feedback.assisted_digital_help_with_fees_spreadsheet).to receive(:store).with(subject.as_row_data)
        subject.save
      end

      it "should raise an exception if the google spreadsheet communication doesn't work" do
        allow(Feedback.assisted_digital_help_with_fees_spreadsheet).to receive(:store).and_raise(GoogleSpreadsheetStore::Error.new('uh-oh!'))
        expect { subject.save }.to raise_error(GoogleSpreadsheetStore::Error, 'uh-oh!')
      end
    end
  end

  context 'an invalid feedback item' do
    subject { described_class.new({}) }

    context '#save' do
      it 'does not send the options to be stored in the google spreadsheet' do
        expect(Feedback.assisted_digital_help_with_fees_spreadsheet).not_to receive(:store)
        subject.save
      end
    end
  end

  context 'validations' do
    it { is_expected.not_to allow_value(nil).for(:assistance_received) }
    it { is_expected.to validate_inclusion_of(:assistance_received).in_array(%w(yes no)) }

    context 'when no assistance was received' do
      subject { described_class.new(assistance_received: 'no') }

      it { is_expected.to allow_value(nil).for(:assistance_received_comments) }
      it { is_expected.to allow_value(nil).for(:assistance_provided_by) }
      it { is_expected.to allow_value(nil).for(:assistance_satisfaction_rating) }
      it { is_expected.to allow_value(nil).for(:assistance_provided_by_other) }
      it { is_expected.to allow_value(nil).for(:assistance_improvement_comments) }
    end

    context 'when assistance was received' do
      subject { described_class.new(assistance_received: 'yes') }

      it { is_expected.not_to allow_value(nil).for(:assistance_received_comments) }
      it { is_expected.to validate_length_of(:assistance_received_comments).is_at_most(Ticket::FIELD_MAXIMUM_CHARACTER_COUNT).with_long_message(/can be max 1250 characters/) }
      it { is_expected.not_to allow_value(nil).for(:assistance_provided_by) }
      it { is_expected.to validate_inclusion_of(:assistance_provided_by).in_array(%w(friend-relative work-colleague government-staff other)) }
      it { is_expected.to allow_value(nil).for(:assistance_improvement_comments) }

      context 'and assistance was provided by "other"' do
        subject { described_class.new(assistance_received: 'yes', assistance_provided_by: 'other') }

        it { is_expected.not_to allow_value(nil).for(:assistance_provided_by_other) }
        it { is_expected.not_to allow_value(nil).for(:assistance_satisfaction_rating) }
        it { is_expected.to validate_inclusion_of(:assistance_satisfaction_rating).in_array(('1'..'5').to_a) }
        it { is_expected.to validate_length_of(:assistance_improvement_comments).is_at_most(Ticket::FIELD_MAXIMUM_CHARACTER_COUNT).with_long_message(/can be max 1250 characters/) }
      end

      context 'and assistance was provided by "government-staff"' do
        subject { described_class.new(assistance_received: 'yes', assistance_provided_by: 'government-staff') }

        it { is_expected.to allow_value(nil).for(:assistance_provided_by_other) }
        it { is_expected.not_to allow_value(nil).for(:assistance_satisfaction_rating) }
        it { is_expected.to validate_inclusion_of(:assistance_satisfaction_rating).in_array(('1'..'5').to_a) }
        it { is_expected.to validate_length_of(:assistance_improvement_comments).is_at_most(Ticket::FIELD_MAXIMUM_CHARACTER_COUNT).with_long_message(/can be max 1250 characters/) }
      end

      context 'and assistance was provided by "work-colleague"' do
        subject { described_class.new(assistance_received: 'yes', assistance_provided_by: 'work-colleague') }

        it { is_expected.to allow_value(nil).for(:assistance_provided_by_other) }
        it { is_expected.to allow_value(nil).for(:assistance_satisfaction_rating) }
      end

      context 'and assistance was provided by "friend-relative"' do
        subject { described_class.new(assistance_received: 'yes', assistance_provided_by: 'friend-relative') }

        it { is_expected.to allow_value(nil).for(:assistance_provided_by_other) }
        it { is_expected.to allow_value(nil).for(:assistance_satisfaction_rating) }
      end
    end

    it { is_expected.not_to allow_value(nil).for(:service_satisfaction_rating) }
    it { is_expected.to validate_inclusion_of(:service_satisfaction_rating).in_array(('1'..'5').to_a) }

    it { is_expected.to allow_value(nil).for(:improvement_comments) }
    it { is_expected.to validate_length_of(:improvement_comments).is_at_most(Ticket::FIELD_MAXIMUM_CHARACTER_COUNT).with_long_message(/can be max 1250 characters/) }

    it { is_expected.to validate_length_of(:slug).is_at_most(512) }
  end

  describe '#as_row_data' do
    subject { described_class.new(params).as_row_data }
    let(:params) do
      {
        assistance_received: 'yes',
        assistance_received_comments: 'I was walked through the online process on my own computer',
        assistance_provided_by: 'other',
        assistance_provided_by_other: 'A helpful librarian at my local drop-in center',
        assistance_satisfaction_rating: '5',
        assistance_improvement_comments: 'Make it easy to book a session',
        service_satisfaction_rating: "4",
        improvement_comments: "it was fine",
        slug: "some-transaction",
        url: "https://www.gov.uk/done/some-transaction",
        referrer: "https://www.some-transaction.service.gov/uk/completed",
        user_agent: "Mozilla-compatible, Foofari WebKat Chrume 111111.01",
        javascript_enabled: true
      }
    end

    it 'exposes an array of 15 elements' do
      expect(subject.size).to eq 15
    end

    it 'exposes `assistance_received` in the first cell' do
      expect(subject[0]).to eq 'yes'
    end

    context 'when assistance was received' do
      let(:params) { super().merge(assistance_received: 'yes') }
      it 'exposes `assistance_received_comments` in the second cell' do
        expect(subject[1]).to eq 'I was walked through the online process on my own computer'
      end

      it 'exposes `assistance_provided_by` in the third cell' do
        expect(subject[2]).to eq 'other'
      end

      context 'when assistance was provided by "other"' do
        let(:params) { super().merge(assistance_provided_by: 'other') }

        it 'exposes `assistance_provided_by_other` in the fourth cell' do
          expect(subject[3]).to eq 'A helpful librarian at my local drop-in center'
        end

        it 'exposes `assistance_satisfaction_rating` in the fifth cell as an integer' do
          expect(subject[4]).to eq 5
        end

        it 'exposes `assistance_improvement_comments` in the sixth cell' do
          expect(subject[5]).to eq 'Make it easy to book a session'
        end
      end

      context 'when assistance was provided by "government-staff"' do
        let(:params) { super().merge(assistance_provided_by: 'government-staff') }

        it 'exposes nil in the fourth cell' do
          expect(subject[3]).to be_nil
        end

        it 'exposes `assistance_satisfaction_rating` in the fifth cell as an integer' do
          expect(subject[4]).to eq 5
        end

        it 'exposes `assistance_improvement_comments` in the sixth cell' do
          expect(subject[5]).to eq 'Make it easy to book a session'
        end
      end

      context 'when assistance was provided by "work-colleague"' do
        let(:params) { super().merge(assistance_provided_by: 'work-colleague') }

        it 'exposes nil in the fourth cell' do
          expect(subject[3]).to be_nil
        end

        it 'exposes nil in the fifth cell as an integer' do
          expect(subject[4]).to be_nil
        end

        it 'exposes nil in the sixth cell' do
          expect(subject[5]).to be_nil
        end
      end

      context 'when assistance was provided by "friend-relative"' do
        let(:params) { super().merge(assistance_provided_by: 'friend-relative') }

        it 'exposes nil in the fourth cell' do
          expect(subject[3]).to be_nil
        end

        it 'exposes nil in the fifth cell as an integer' do
          expect(subject[4]).to be_nil
        end

        it 'exposes nil in the sixth cell' do
          expect(subject[5]).to be_nil
        end
      end
    end

    context 'when assistance was not received' do
      let(:params) { super().merge(assistance_received: 'no') }

      it 'exposes nil in the second cell' do
        expect(subject[1]).to be_nil
      end

      it 'exposes nil in the third cell' do
        expect(subject[2]).to be_nil
      end

      it 'exposes nil in the fourth cell' do
        expect(subject[3]).to be_nil
      end

      it 'exposes nil in the fifth cell' do
        expect(subject[4]).to be_nil
      end

      it 'exposes nil in the sixth cell' do
        expect(subject[5]).to be_nil
      end
    end

    it 'exposes `service_satisfaction_rating` in the seventh cell as an integer' do
      expect(subject[6]).to eq 4
    end

    it 'exposes `improvement_comments` in the eigth cell' do
      expect(subject[7]).to eq "it was fine"
    end

    it 'exposes `slug` in the ninth cell' do
      expect(subject[8]).to eq "some-transaction"
    end

    it 'exposes `user_agent` in the tenth cell' do
      expect(subject[9]).to eq "Mozilla-compatible, Foofari WebKat Chrume 111111.01"
    end

    it 'exposes `javascript_enabled` as a boolean in the eleventh cell' do
      expect(subject[10]).to eq true
    end

    it 'exposes the referrer in the twelfth cell' do
      expect(subject[11]).to eq "https://www.some-transaction.service.gov/uk/completed"
    end

    it 'extracts the path from the url and exposes it in the thirteenth cell' do
      expect(subject[12]).to eq '/done/some-transaction'
    end

    it 'exposes `url` in the fourteenth cell' do
      expect(subject[13]).to eq 'https://www.gov.uk/done/some-transaction'
    end

    it 'exposes a timestamp for the current time in the fifteenth cell' do
      # travel_to doesn't respect usec apparently
      the_past = 13.years.ago.change(usec: 0)
      travel_to(the_past) do
        expect(subject[14]).to eq the_past
      end
    end

    context 'javascript_enabled' do
      context 'is provided in params' do
        let(:params) { super().merge(javascript_enabled: "1") }
        it 'exposes a true value' do
          expect(subject[10]).to eq true
        end
      end

      context 'is not provided in params' do
        let(:params) { super().except(:javascript_enabled) }
        it 'exposes a false value' do
          expect(subject[10]).to eq false
        end
      end
    end

    context "with empty assistance_received_comments" do
      let(:params) { super().merge(assistance_received_comments: "") }

      it 'exposes a nil value in the assistance_received_comments cell' do
        expect(subject[1]).to be_nil
      end
    end

    context "with empty assistance_improvement_comments" do
      let(:params) { super().merge(assistance_improvement_comments: "") }

      it 'exposes a nil value in the assistance_improvement_comments cell' do
        expect(subject[5]).to be_nil
      end
    end

    context "with empty improvement_comments" do
      let(:params) { super().merge(improvement_comments: "") }

      it 'exposes a nil value in the eighth cell' do
        expect(subject[7]).to be_nil
      end
    end

    context "with an invalid URL" do
      let(:params) { super().merge(url: "```") }

      it 'exposes a blank path in the path cell' do
        expect(subject[12]).to be_nil
      end

      it 'exposes a blank URL in the url cell' do
        expect(subject[13]).to be_nil
      end
    end

    context "with a relative URL" do
      let(:params) { super().merge(url: "/done/some-transaction") }

      it 'exposes an absolute URL in the url cell' do
        expect(subject[13]).to eq "#{Plek.new.website_root}/done/some-transaction"
      end
    end

    context "with an invalid referrer" do
      let(:params) { super().merge(referrer: "```") }

      it 'exposes a blank referrer in the referrer cell' do
        expect(subject[11]).to be_nil
      end
    end

    context "with a relative referrer" do
      let(:params) { super().merge(referrer: "/some-transaction/completed") }

      it 'exposes an absolute referrer in the referrer cell' do
        expect(subject[11]).to eq "#{Plek.new.website_root}/some-transaction/completed"
      end
    end
  end
end
