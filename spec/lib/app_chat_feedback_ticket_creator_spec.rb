require "rails_helper"

RSpec.describe AppChatFeedbackTicketCreator do
  let(:ticket_params) do
    {
      requester: {
        email: "someone@example.com",
        name: "Someone",
      },
      feedback: "Some feedback",
    }
  end

  let(:support_ticket) { AppChatFeedbackTicketCreator.new(ticket_params) }

  it "should inherit from TicketCreator" do
    expect(AppChatFeedbackTicketCreator.superclass).to eq(TicketCreator)
  end

  it "includes priority" do
    expect(support_ticket.priority).to eq("normal")
  end

  it "includes tags" do
    expect(support_ticket.tags).to eq(%w[govuk_app govuk_app_chat])
  end

  it "includes subject" do
    expect(support_ticket.subject).to eq("Leave feedback about GOV.UK Chat")
  end

  describe "#body" do
    it "returns body text" do
      body = <<~MULTILINE_STRING
        [Requester]
        Someone <someone@example.com>

        [Please leave your feedback]
        Some feedback
      MULTILINE_STRING

      expect(support_ticket.body).to eq(body)
    end

    it "returns anonymous without requester " do
      ticket_params.delete(:requester)
      body = <<~MULTILINE_STRING
        [Requester]
        Anonymous
      MULTILINE_STRING
      expect(support_ticket.body).to include(body)
    end

    it "returns only email if name isn't present" do
      ticket_params[:requester].delete(:name)
      body = <<~MULTILINE_STRING
        [Requester]
        someone@example.com
      MULTILINE_STRING
      expect(support_ticket.body).to include(body)
    end
  end
end
