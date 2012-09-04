require 'spec_helper'

describe FeedbackController do

  describe "GET 'landing'" do
    it "returns http success" do
      get :landing
      response.should be_success
    end
  end

  describe "POST 'submit'" do

    it "should render the thankyou template" do
      post :submit
      response.should render_template('thankyou')
    end
  end

end
