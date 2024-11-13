require "rails_helper"

RSpec.describe AppSuggestionTicket, type: :model do
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
end
