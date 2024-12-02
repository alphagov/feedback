require "rails_helper"
require "gds_api/test_helpers/support_api"

RSpec.describe TicketCreator do
  include GdsApi::TestHelpers::SupportApi

  it "raises an error if a child class has not defined required methods" do
    expect { TestInvalidTicketCreator.new({}).send }.to raise_exception(RuntimeError)
  end

  context "when the ticket creator class is called directly" do
    let(:ticket_creator) { TicketCreator.new({}) }

    it "raises an error if send is called" do
      expect { ticket_creator.send }.to raise_exception(RuntimeError)
    end

    it "raises an error if payload is called" do
      expect { ticket_creator.payload }.to raise_exception(RuntimeError)
    end

    it "raises an error if subject is called" do
      expect { ticket_creator.subject }.to raise_exception("Define subject in child class")
    end

    it "raises an error if body is called" do
      expect { ticket_creator.body }.to raise_exception("Define body in child class")
    end

    it "raises an error if priority is called" do
      expect { ticket_creator.priority }.to raise_exception("Define priority in child class")
    end

    it "raises an error if tags is called" do
      expect { ticket_creator.tags }.to raise_exception("Define tags in child class")
    end
  end

  context "when a valid child ticket class is created" do
    let(:args) do
      {
        requester: {
          email: "someone@example.com",
          name: "Someone",
        },
      }
    end
    let(:ticket_creator_child_class) { TestValidTicketCreator.new(args) }

    it "raises support ticket for given params" do
      request = stub_support_api_valid_raise_support_ticket(
        {
          subject: "Test subject",
          priority: "normal",
          tags: %w[one two three],
          description: "Test body",
          requester: {
            email: "someone@example.com",
            name: "Someone",
          },
        },
      )
      ticket_creator_child_class.send

      expect(request).to have_been_made
    end

    it "raises an error when 422 error is returned" do
      stub_support_api_invalid_raise_support_ticket(ticket_creator_child_class.payload)

      expect { ticket_creator_child_class.send }.to raise_exception(GdsApi::HTTPUnprocessableEntity)
    end

    it "doesn't raise an error when a 422 error is returned for a suspended user" do
      post_stub = stub_http_request(:post, "#{Plek.find('support-api')}/support-tickets")
      post_stub.with(body: ticket_creator_child_class.payload)
      post_stub.to_return(status: 422, body: { status: "error", errors: { requester: ["is suspended in Zendesk"] } }.to_json)

      expect { ticket_creator_child_class.send }.not_to raise_exception
    end
  end
end

class TestValidTicketCreator < TicketCreator
  def subject
    "Test subject"
  end

  def body
    "Test body"
  end

  def priority
    "normal"
  end

  def tags
    %w[one two three]
  end
end

class TestInvalidTicketCreator < TicketCreator; end
