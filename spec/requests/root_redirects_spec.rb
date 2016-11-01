require 'rails_helper'

RSpec.describe "Redirecting the root URL", type: :request do
  specify "visiting the root URL redirects me to the contact index page", allow_rescue: true do
    get "/"

    expect(response).to redirect_to("/contact")
  end
end
