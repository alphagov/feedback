require "rails_helper"

RSpec.describe AppSuggestionTicket, type: :model do
  include ValidatorHelper

  let(:ticket_details) do
    {
      details: "A good suggestion",
      reply: "yes",
      name: "Zeus",
      email: "somthing@something.com",
    }
  end
  let(:ticket_creator) do
    instance_double(AppSuggestionTicketCreator)
  end

  context "when the ticket is valid" do
    it "sends a ticket on save" do
      ticket_creator_args = {
        details: ticket_details[:details],
        requester: {
          name: ticket_details[:name],
          email: ticket_details[:email],
        },
      }
      allow(AppSuggestionTicketCreator).to receive(:new)
        .with(ticket_creator_args) { ticket_creator }
      allow(ticket_creator).to receive(:send)

      AppSuggestionTicket.new(ticket_details).save

      expect(ticket_creator).to have_received(:send)
    end

    it "sends a ticket on save when missing name" do
      ticket_details[:name] = ""
      ticket_creator_args = {
        details: ticket_details[:details],
        requester: {
          name: "Not submitted",
          email: ticket_details[:email],
        },
      }
      allow(AppSuggestionTicketCreator).to receive(:new)
        .with(ticket_creator_args) { ticket_creator }
      allow(ticket_creator).to receive(:send)

      AppSuggestionTicket.new(ticket_details).save

      expect(ticket_creator).to have_received(:send)
    end

    it "sends a ticket on save with no requester details" do
      ticket_details[:reply] = "no"
      ticket_details[:name] = ""
      ticket_details[:email] = ""
      ticket_creator_args = { details: ticket_details[:details] }
      allow(AppSuggestionTicketCreator).to receive(:new)
        .with(ticket_creator_args) { ticket_creator }
      allow(ticket_creator).to receive(:send)

      AppSuggestionTicket.new(ticket_details).save

      expect(ticket_creator).to have_received(:send)
    end
  end

  context "when the ticket is invalid" do
    it "returns an error if details is missing" do
      ticket_details.delete(:details)
      ticket = AppSuggestionTicket.new(ticket_details)

      ticket.save

      expect(ticket.errors[:details]).to eq(
        ["Enter your suggestion"],
      )
    end

    it "returns an error if suggestion has too many characters" do
      ticket_details[:details] = build_random_string(1251)
      ticket = AppSuggestionTicket.new(ticket_details)

      ticket.save

      expect(ticket.errors[:details]).to eq(
        ["Your suggestion must be 1250 characters or less"],
      )
    end
  end
end
