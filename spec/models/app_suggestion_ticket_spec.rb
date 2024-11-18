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

  it "doesn't create a ticket if giraffe field present" do
    ticket_details[:giraffe] = "I am a robot"
    allow(AppSuggestionTicketCreator).to receive(:new)
      .with(anything) { ticket_creator }
    allow(ticket_creator).to receive(:send)
    ticket = AppSuggestionTicket.new(ticket_details)

    ticket.save

    expect(ticket_creator).to_not have_received(:send)
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

  context "when the ticket is invalid" do
    it "returns an error if details is missing" do
      ticket_details.delete(:details)
      ticket = AppSuggestionTicket.new(ticket_details)

      ticket.save

      expect(ticket.errors[:details]).to eq(
        ["Enter your suggestion"],
      )
    end

    it "returns an error if reply is missing" do
      ticket_details[:reply] = ""
      ticket = AppSuggestionTicket.new(ticket_details)

      ticket.save

      expect(ticket.errors[:reply]).to eq(
        ["Select a reply option"],
      )
    end

    it "returns an error if reply equals yes but email missing" do
      ticket_details[:email] = ""
      ticket = AppSuggestionTicket.new(ticket_details)

      ticket.save

      expect(ticket.errors[:email]).to eq(
        ["Please add an email address"],
      )
    end

    it "returns an error if the email is invalid" do
      ticket_details[:email] = "doggo"
      ticket = AppSuggestionTicket.new(ticket_details)

      ticket.save

      expect(ticket.errors[:email]).to eq(
        ["The email address must be valid"],
      )
    end
  end
end
