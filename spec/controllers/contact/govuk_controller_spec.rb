require 'spec_helper'
require 'gds_api/test_helpers/support'

describe Contact::GovukController do
  include GdsApi::TestHelpers::Support

  let(:valid_params) do
    {
      contact: {
        name: "Joe Bloggs",
        email: "test@test.com",
        location: "all",
        textdetails: "Testing, testing, 1, 2, 3...",
      }
    }
  end

  it_behaves_like "a GOV.UK contact"

  context "with a valid contact submission" do
    it "should pass the contact onto the support app" do
      stub_post = stub_support_named_contact_creation

      post :create, valid_params

      expect(response).to be_redirect
      expect(stub_post).to have_been_made
    end
  end
end
