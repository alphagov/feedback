require 'spec_helper'
require 'gds_api/test_helpers/support'

describe Contact::FoiController do
  include GdsApi::TestHelpers::Support

  let(:valid_params) do
    { 
      foi: {
        name: "test name",
        email: "a@a.com",
        email_confirmation: "a@a.com",
        textdetails: "test foi"
      }
    }
  end

  it_behaves_like "a GOV.UK contact"

  context "with a valid contact submission" do
    it "should pass the contact onto the support app" do
      stub_post = stub_support_foi_request_creation

      post :create, valid_params

      response.should be_success
      stub_post.should have_been_made
    end
  end
end
