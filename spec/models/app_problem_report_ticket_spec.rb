require "rails_helper"

RSpec.describe AppProblemReportTicket, type: :model do
  include ValidatorHelper

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

    it "returns an error if phone has too many characters" do
      ticket_details[:phone] = build_random_string(1251)
      ticket = AppProblemReportTicket.new(ticket_details)

      ticket.save

      expect(ticket.errors[:phone]).to eq(
        ["Details about your phone must be 1250 characters or less"],
      )
    end

    it "returns an error if app_version has too many characters" do
      ticket_details[:app_version] = build_random_string(1251)
      ticket = AppProblemReportTicket.new(ticket_details)

      ticket.save

      expect(ticket.errors[:app_version]).to eq(
        ["The app version must be 1250 characters or less"],
      )
    end

    it "returns an error if trying_to_do has too many characters" do
      ticket_details[:trying_to_do] = build_random_string(1251)
      ticket = AppProblemReportTicket.new(ticket_details)

      ticket.save

      expect(ticket.errors[:trying_to_do]).to eq(
        ["Details about what you were trying to do must be 1250 characters or less"],
      )
    end

    it "returns an error if what_happened has too many characters" do
      ticket_details[:what_happened] = build_random_string(1251)
      ticket = AppProblemReportTicket.new(ticket_details)

      ticket.save

      expect(ticket.errors[:what_happened]).to eq(
        ["Details about what the problem was must be 1250 characters or less"],
      )
    end
  end
end
