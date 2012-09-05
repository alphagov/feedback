require 'spec_helper'

describe FeedbackController do

  describe "GET 'landing'" do
    it "returns http success" do
      get :landing
      response.should be_success
    end

    it "should set cache control headers for 10 mins" do
      get :landing
      response.headers["Cache-Control"].should == "max-age=600, public"
    end
  end

end
