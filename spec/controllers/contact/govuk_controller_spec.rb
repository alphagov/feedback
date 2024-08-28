require "rails_helper"
require "gds_api/test_helpers/support_api"

RSpec.describe Contact::GovukController, type: :controller do
  include GdsApi::TestHelpers::SupportApi

  render_views

  let(:valid_params) do
    {
      contact: {
        name: "Joe Bloggs",
        email: "test@test.com",
        location: "all",
        textdetails: "Testing, testing, 1, 2, 3...",
      },
    }
  end

  let(:ticket_creator_params) do
    {
      details: "Testing, testing, 1, 2, 3...",
      link: nil,
      user_specified_url: nil,
      user_agent: "Rails Testing",
      referrer: nil,
      javascript_enabled: false,
      url: nil,
      path: nil,
      requester: {
        name: "Joe Bloggs",
        email: "test@test.com",
      },
    }
  end

  let(:support_ticket) { SupportTicketCreator.new(ticket_creator_params) }

  it_behaves_like "a GOV.UK contact"

  context "with a valid contact submission" do
    it "should pass the contact onto the support api" do
      stub_post = stub_support_api_valid_raise_support_ticket(support_ticket.payload)

      post :create, params: valid_params

      expect(response).to be_redirect
      expect(stub_post).to have_been_made
    end
  end
end
