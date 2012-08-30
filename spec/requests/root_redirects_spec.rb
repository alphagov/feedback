require 'spec_helper'

describe "Redirecting the root URL" do

  specify "visiting the root URL redirects me to the feedback page", :allow_rescue => true do
    get "/"

    response.should redirect_to("/feedback")
  end
end
