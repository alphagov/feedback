require "rails_helper"

RSpec.describe AppChatFeedbackTicket, type: :model do
  include ValidatorHelper

  let(:ticket_feedback) do
    {
      feedback: "Some feedback",
      reply: "yes",
      name: "Zeus",
      email: "somthing@something.com",
    }
  end
  let(:ticket_creator) do
    instance_double(AppChatFeedbackTicketCreator)
  end

  context "when the ticket is valid" do
    it "sends a ticket on save" do
      ticket_creator_args = {
        feedback: ticket_feedback[:feedback],
        requester: {
          name: ticket_feedback[:name],
          email: ticket_feedback[:email],
        },
      }
      allow(AppChatFeedbackTicketCreator).to receive(:new)
        .with(ticket_creator_args) { ticket_creator }
      allow(ticket_creator).to receive(:send)

      described_class.new(ticket_feedback).save

      expect(ticket_creator).to have_received(:send)
    end

    it "sends a ticket on save when missing name" do
      ticket_feedback[:name] = ""
      ticket_creator_args = {
        feedback: ticket_feedback[:feedback],
        requester: {
          name: "Not submitted",
          email: ticket_feedback[:email],
        },
      }
      allow(AppChatFeedbackTicketCreator).to receive(:new)
        .with(ticket_creator_args) { ticket_creator }
      allow(ticket_creator).to receive(:send)

      described_class.new(ticket_feedback).save

      expect(ticket_creator).to have_received(:send)
    end

    it "sends a ticket on save with no requester feedback" do
      ticket_feedback[:reply] = "no"
      ticket_feedback[:name] = ""
      ticket_feedback[:email] = ""
      ticket_creator_args = { feedback: ticket_feedback[:feedback] }
      allow(AppChatFeedbackTicketCreator).to receive(:new)
        .with(ticket_creator_args) { ticket_creator }
      allow(ticket_creator).to receive(:send)

      described_class.new(ticket_feedback).save

      expect(ticket_creator).to have_received(:send)
    end
  end

  context "when the ticket is invalid" do
    it "returns an error if feedback is missing" do
      ticket_feedback.delete(:feedback)
      ticket = described_class.new(ticket_feedback)

      ticket.save

      expect(ticket.errors[:feedback]).to eq(
        ["Enter your feedback"],
      )
    end

    it "returns an error if feedback has too many characters" do
      ticket_feedback[:feedback] = build_random_string(1251)
      ticket = described_class.new(ticket_feedback)

      ticket.save

      expect(ticket.errors[:feedback]).to eq(
        ["Your feedback must be 1250 characters or less"],
      )
    end
  end
end
