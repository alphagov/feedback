require "rails_helper"
require "gds_api/test_helpers/support_api"

RSpec.describe SupportTicketCreator do
  include GdsApi::TestHelpers::SupportApi

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

  let(:support_ticket) { SupportTicketCreator.new(args) }

  describe ".call" do
    it "sends input via instance" do
      stub_any_support_api_call

      expect { SupportTicketCreator.call(args) }.to_not raise_exception
    end

    it "ignores any extra keyword arguments" do
      stub_any_support_api_call
      messy_args = args.merge(foo: "bar")

      expect { SupportTicketCreator.call(messy_args) }.to_not raise_exception
    end

    it "raises an error when 422 error is returned" do
      stub_support_api_invalid_raise_support_ticket(support_ticket.payload)

      expect { SupportTicketCreator.call(args) }.to raise_exception(GdsApi::HTTPUnprocessableEntity)
    end

    it "doesn't raise an error when a 422 error is returned for a suspended user" do
      post_stub = stub_http_request(:post, "#{Plek.find('support-api')}/support-tickets")
      post_stub.with(body: support_ticket.payload)
      post_stub.to_return(status: 422, body: { status: "error", errors: { requester: ["is suspended in Zendesk"] } }.to_json)

      expect { SupportTicketCreator.call(args) }.not_to raise_exception
    end
  end

  describe "#send" do
    it "sends payload to Support API" do
      stub_any_support_api_call

      expect { support_ticket.send }.to_not raise_exception
    end
  end

  describe "#payload" do
    it "includes hardcoded subject" do
      expect(support_ticket.payload[:subject]).to eq("Named contact")
    end

    it "includes dynamic subject if link provided" do
      args[:link] = "https://www.gov.uk/browse/visas-immigration"
      expect(support_ticket.payload[:subject]).to eq("Named contact about /browse/visas-immigration")
    end

    it "includes hardcoded tags" do
      expect(support_ticket.payload[:tags]).to eq(%w[public_form named_contact])
    end

    it "includes hardcoded priority" do
      expect(support_ticket.payload[:priority]).to eq("normal")
    end

    it "includes 'comment' containing generated body" do
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

      expect(support_ticket.payload[:description]).to eq(body)
    end

    it "defaults to 'Unknown' for referrer and user agent" do
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

      expect(support_ticket.payload[:description]).to eq(body)
    end
  end
end
