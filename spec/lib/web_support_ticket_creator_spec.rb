require "rails_helper"

RSpec.describe WebSupportTicketCreator do
  let(:args) do
    {
      requester: {
        email: "someone@example.com",
        name: "Someone",
      },
      details: "Foo",
      link: "link",
      referrer: "Referrer",
      user_agent: "User agent",
      javascript_enabled: true,
    }
  end

  let(:support_ticket) { WebSupportTicketCreator.new(args) }

  it "should inherit from TicketCreator" do
    expect(WebSupportTicketCreator.superclass).to eq(TicketCreator)
  end

  it "includes priority" do
    expect(support_ticket.priority).to eq("normal")
  end

  it "includes tags" do
    expect(support_ticket.tags).to eq(%w[public_form named_contact])
  end

  describe "#subject" do
    it "includes subject" do
      expect(support_ticket.subject).to eq("Named contact")
    end

    it "includes dynamic subject if link provided" do
      args[:link] = "https://www.gov.uk/browse/visas-immigration"
      expect(support_ticket.subject).to eq("Named contact about /browse/visas-immigration")
    end
  end

  describe "#body" do
    it "returns body text" do
      body = <<~MULTILINE_STRING
        [Requester]
        Someone <someone@example.com>

        [Details]
        Foo

        [Link]
        link

        [Referrer]
        Referrer

        [User agent]
        User agent

        [JavaScript Enabled]
        true
      MULTILINE_STRING

      expect(support_ticket.body).to eq(body)
    end

    it "returns body text, defaulting to 'Unknown' for referrer and user agent" do
      args.delete(:referrer)
      args.delete(:user_agent)

      body = <<~MULTILINE_STRING
        [Requester]
        Someone <someone@example.com>

        [Details]
        Foo

        [Link]
        link

        [Referrer]
        Unknown

        [User agent]
        Unknown

        [JavaScript Enabled]
        true
      MULTILINE_STRING

      expect(support_ticket.body).to eq(body)
    end
  end
end
