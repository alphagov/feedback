require "rails_helper"

RSpec.describe MultiTicket, type: :model do
  subject { described_class.new(ServiceFeedback, AssistedDigitalFeedback) }

  context "#new" do
    it "stores the supplied ticket types" do
      expect(subject.ticket_types).to eq [ServiceFeedback, AssistedDigitalFeedback]
    end
  end

  context ".new" do
    subject { super().new(assistance_received: "no", service_satisfaction_rating: "1") }

    it "returns a multiticket instance" do
      expect(subject).to be_a MultiTicket::Instance
    end

    it "stores an instance of each ticket type" do
      expect(subject.tickets.size).to eq 2
      expect(subject.tickets.first).to be_a ServiceFeedback
      expect(subject.tickets.last).to be_an AssistedDigitalFeedback
    end

    it "supplies all the data to each ticket instance" do
      service_ticket = subject.tickets.first

      expect(service_ticket.service_satisfaction_rating).to eq("1")

      assisted_digital_ticket = subject.tickets.last
      expect(assisted_digital_ticket.service_satisfaction_rating).to eq("1")
      expect(assisted_digital_ticket.assistance_received).to eq("no")
    end
  end

  describe MultiTicket::Instance do
    subject { MultiTicket.new(ServiceFeedback, AssistedDigitalFeedback).new(data) }
    let(:data) do
      {
        assistance_received: "no",
        service_satisfaction_rating: "1",
      }
    end
    let(:service_ticket) { subject.tickets.first }
    let(:assisted_digital_ticket) { subject.tickets.last }

    context ".valid?" do
      it "is vaild if all the tickets are valid" do
        allow(service_ticket).to receive(:valid?).and_return true
        allow(assisted_digital_ticket).to receive(:valid?).and_return true

        expect(subject).to be_valid
      end

      it "is not vaild if one of the tickets not valid" do
        allow(service_ticket).to receive(:valid?).and_return true
        allow(assisted_digital_ticket).to receive(:valid?).and_return false

        expect(subject).not_to be_valid

        allow(service_ticket).to receive(:valid?).and_return false
        allow(assisted_digital_ticket).to receive(:valid?).and_return true

        expect(subject).not_to be_valid
      end

      it "is not vaild if all of the tickets not valid" do
        allow(service_ticket).to receive(:valid?).and_return false
        allow(assisted_digital_ticket).to receive(:valid?).and_return false

        expect(subject).not_to be_valid
      end
    end

    context ".save" do
      it "it asks each ticket to save" do
        expect(service_ticket).to receive(:save)
        expect(assisted_digital_ticket).to receive(:save)

        subject.save
      end

      it "it does not continue to the next ticket and raises the error if one of the tickets errors out while saving" do
        expect(service_ticket).to receive(:save).and_raise "Uh-oh"
        expect(assisted_digital_ticket).not_to receive(:save)

        expect { subject.save }.to raise_error(RuntimeError, "Uh-oh")
      end
    end

    context ".spam?" do
      it "is spam if all the tickets are spam" do
        allow(service_ticket).to receive(:spam?).and_return true
        allow(assisted_digital_ticket).to receive(:spam?).and_return true

        expect(subject).to be_spam
      end

      it "is spam if one of the tickets spam" do
        allow(service_ticket).to receive(:spam?).and_return true
        allow(assisted_digital_ticket).to receive(:spam?).and_return false

        expect(subject).to be_spam

        allow(service_ticket).to receive(:spam?).and_return false
        allow(assisted_digital_ticket).to receive(:spam?).and_return true

        expect(subject).to be_spam
      end

      it "is not spam if none of the tickets are spam" do
        allow(service_ticket).to receive(:spam?).and_return false
        allow(assisted_digital_ticket).to receive(:spam?).and_return false

        expect(subject).not_to be_spam
      end
    end

    context ".errors" do
      it "is empty if none of the tickets have any errors" do
        allow(service_ticket).to receive(:errors).and_return ActiveModel::Errors.new(service_ticket)
        allow(assisted_digital_ticket).to receive(:errors).and_return ActiveModel::Errors.new(assisted_digital_ticket)

        expect(subject.errors).to be_empty
      end

      it "is not empty if there are errors on any of the tickets have any errors" do
        service_errors = ActiveModel::Errors.new(service_ticket)
        service_errors.add(:improvement_comments, "is too long")
        allow(service_ticket).to receive(:errors).and_return service_errors
        allow(assisted_digital_ticket).to receive(:errors).and_return ActiveModel::Errors.new(assisted_digital_ticket)

        expect(subject.errors).not_to be_empty

        allow(service_ticket).to receive(:errors).and_return ActiveModel::Errors.new(service_ticket)

        assisted_digital_errors = ActiveModel::Errors.new(assisted_digital_ticket)
        assisted_digital_errors.add(:improvement_comments, "is too long")
        allow(assisted_digital_ticket).to receive(:errors).and_return assisted_digital_errors

        expect(subject.errors).not_to be_empty
      end

      it "collects all the errors from each ticket and re-presents them as one" do
        service_errors = ActiveModel::Errors.new(service_ticket)
        service_errors.add(:improvement_comments, "is too long")
        service_errors.add(:service_satisfaction_rating, "is invalid")
        allow(service_ticket).to receive(:errors).and_return service_errors

        assisted_digital_errors = ActiveModel::Errors.new(assisted_digital_ticket)
        assisted_digital_errors.add(:improvement_comments, "is not long enough")
        assisted_digital_errors.add(:assistance_received, "is invalid")
        allow(assisted_digital_ticket).to receive(:errors).and_return assisted_digital_errors

        expect(subject.errors[:improvement_comments]).to eq ["is too long", "is not long enough"]
        expect(subject.errors[:service_satisfaction_rating]).to eq ["is invalid"]
        expect(subject.errors[:assistance_received]).to eq ["is invalid"]
      end
    end
  end
end
