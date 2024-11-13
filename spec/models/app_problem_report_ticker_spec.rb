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
end
