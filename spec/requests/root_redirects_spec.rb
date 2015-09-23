require 'spec_helper'

describe "Redirecting the root URL" do
  specify "visiting the root URL redirects me to the contact index page", allow_rescue: true do
    get "/"

    expect(response).to redirect_to("/contact")
  end
end
