require "rails_helper"

RSpec.describe AppSuggestionTicketCreator do
  let(:ticket_params) do
    {
      requester: {
        email: "someone@example.com",
        name: "Someone",
      },
      details: "Do something good",
    }
  end

  let(:support_ticket) { AppSuggestionTicketCreator.new(ticket_params) }

  it "should inherit from TicketCreator" do
    expect(AppSuggestionTicketCreator.superclass).to eq(TicketCreator)
  end

  it "includes priority" do
    expect(support_ticket.priority).to eq("normal")
  end

  it "includes tags" do
    expect(support_ticket.tags).to eq(%w[govuk_app govuk_app_suggestion])
  end

  it "includes subject" do
    expect(support_ticket.subject).to eq("Suggestion")
  end

  describe "#body" do
    it "returns body text" do
      body = <<~MULTILINE_STRING
        [Requester]
        Someone <someone@example.com>

        [What is your suggestion?]
        Do something good
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
