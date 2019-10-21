require "rails_helper"

RSpec.describe Contact::ContactController, type: :controller do
  context "when content store is returning a 403" do
    before do
      # Visiting https://draft-origin.publishing.service.gov.uk/contact/govuk
      # with a token cookie exhibits the issue
      stub_request(:get, "#{Plek.find('content-store')}/content/contact").
        to_return(status: 403, headers: {})
    end

    it "should return 403" do
      get :new, params: {} # TBC

      expect(response.status).to eq 403
    end
  end
end
