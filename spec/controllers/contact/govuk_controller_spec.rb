require 'rails_helper'
require 'gds_api/test_helpers/support'

RSpec.describe Contact::GovukController, type: :controller do
  render_views

  include GdsApi::TestHelpers::Support

  let(:valid_params) do
    {
      contact: {
        name: "Joe Bloggs",
        email: "test@test.com",
        location: "all",
        textdetails: "Testing, testing, 1, 2, 3...",
        govuk_thanks_martha: "",
      }
    }
  end

  let(:params_with_hidden_field_filled) do
    {
      contact: {
        name: "Joe Bloggs",
        email: "test@test.com",
        location: "all",
        textdetails: "Testing, testing, 1, 2, 3...",
        govuk_thanks_martha: "We are the robots",
      }
    }
  end



  it_behaves_like "a GOV.UK contact"

  context "with a valid contact submission" do
    it "should pass the contact onto the support app" do
      stub_post = stub_support_named_contact_creation

      post :create, params: valid_params

      expect(response).to be_redirect
      expect(stub_post).to have_been_made
    end
  end

  context "with a filled in hidden form" do
    it "should redirect to the anonymous feedback thank you" do
      stub_post = stub_support_named_contact_creation

      post :create, params: params_with_hidden_field_filled

      expect(stub_post).to_not have_been_made
    end
  end
end
