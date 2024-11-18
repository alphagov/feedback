require "rails_helper"

RSpec.describe AppProblemReportTicket, type: :model do
  let(:ticket_details) do
    {
      phone: "iPhone 15",
      app_version: "1.0",
      trying_to_do: "Something",
      what_happened: "Something bad",
      reply: "yes",
      name: "Zeus",
      email: "somthing@something.com",
    }
  end
  let(:ticket_creator) do
    instance_double(AppProblemReportTicketCreator)
  end

  it "doesn't create a ticket if giraffe field present" do
    ticket_details[:giraffe] = "I am a robot"
    allow(AppProblemReportTicketCreator).to receive(:new)
      .with(anything) { ticket_creator }
    allow(ticket_creator).to receive(:send)
    ticket = AppProblemReportTicket.new(ticket_details)

    ticket.save

    expect(ticket_creator).to_not have_received(:send)
  end

  context "when the ticket is valid" do
    it "sends a ticket on save" do
      ticket_creator_args = {
        phone: ticket_details[:phone],
        app_version: ticket_details[:app_version],
        trying_to_do: ticket_details[:trying_to_do],
        what_happened: ticket_details[:what_happened],
        requester: {
          name: ticket_details[:name],
          email: ticket_details[:email],
        },
      }
      allow(AppProblemReportTicketCreator).to receive(:new)
        .with(ticket_creator_args) { ticket_creator }
      allow(ticket_creator).to receive(:send)

      AppProblemReportTicket.new(ticket_details).save

      expect(ticket_creator).to have_received(:send)
    end

    it "sends a ticket on save with no requester details" do
      ticket_details[:reply] = "no"
      ticket_details[:name] = ""
      ticket_details[:email] = ""
      ticket_creator_args = {
        phone: ticket_details[:phone],
        app_version: ticket_details[:app_version],
        trying_to_do: ticket_details[:trying_to_do],
        what_happened: ticket_details[:what_happened],
      }
      allow(AppProblemReportTicketCreator).to receive(:new)
        .with(ticket_creator_args) { ticket_creator }
      allow(ticket_creator).to receive(:send)

      AppProblemReportTicket.new(ticket_details).save

      expect(ticket_creator).to have_received(:send)
    end
  end

  context "when the ticket is invalid" do
    it "returns an error if trying_to_do is missing" do
      ticket_details[:trying_to_do] = ""
      ticket = AppProblemReportTicket.new(ticket_details)

      ticket.save

      expect(ticket.errors[:trying_to_do]).to eq(
        ["Enter details about what you were trying to do"],
      )
    end

    it "returns an error if what_happened is missing" do
      ticket_details[:what_happened] = ""
      ticket = AppProblemReportTicket.new(ticket_details)

      ticket.save

      expect(ticket.errors[:what_happened]).to eq(
        ["Enter details about what the problem was"],
      )
    end

    it "returns an error if reply is missing" do
      ticket_details[:reply] = ""
      ticket = AppProblemReportTicket.new(ticket_details)

      ticket.save

      expect(ticket.errors[:reply]).to eq(
        ["Select a reply option"],
      )
    end

    it "returns an error if reply equals yes but email missing" do
      ticket_details[:email] = ""
      ticket = AppProblemReportTicket.new(ticket_details)

      ticket.save

      expect(ticket.errors[:email]).to eq(
        ["Please add an email address"],
      )
    end

    it "returns an error if the email is invalid" do
      ticket_details[:email] = "doggo"
      ticket = AppProblemReportTicket.new(ticket_details)

      ticket.save

      expect(ticket.errors[:email]).to eq(
        ["The email address must be valid"],
      )
    end
  end
end
