require "rails_helper"

RSpec.describe AppProblemReportTicketCreator do
  let(:ticket_params) do
    {
      requester: {
        email: "someone@example.com",
        name: "Someone",
      },
      phone: "iPhone 15",
      app_version: "1.0",
      trying_to_do: "Something",
      what_happened: "Something bad",
    }
  end

  let(:support_ticket) { AppProblemReportTicketCreator.new(ticket_params) }

  it "should inherit from TicketCreator" do
    expect(AppProblemReportTicketCreator.superclass).to eq(TicketCreator)
  end

  it "includes priority" do
    expect(support_ticket.priority).to eq("normal")
  end

  it "includes tags" do
    expect(support_ticket.tags).to eq(%w[govuk_app govuk_app_problem_report])
  end

  it "includes subject" do
    expect(support_ticket.subject).to eq("Problem report")
  end

  describe "#body" do
    it "returns body text" do
      body = <<~MULTILINE_STRING
        [Requester]
        Someone <someone@example.com>

        [Phone]
        iPhone 15

        [App version]
        1.0

        [What were you trying to do?]
        Something

        [What happened?]
        Something bad
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

    it "returns not submitted for phone and app version if not present" do
      ticket_params.delete(:phone)
      ticket_params.delete(:app_version)
      body = <<~MULTILINE_STRING
        [Phone]
        Not submitted

        [App version]
        Not submitted
      MULTILINE_STRING
      expect(support_ticket.body).to include(body)
    end
  end
end
