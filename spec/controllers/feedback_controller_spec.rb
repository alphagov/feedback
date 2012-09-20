require 'spec_helper'

describe FeedbackController do

  describe "GET 'index'" do
    it "returns http success" do
      get :index
      response.should be_success
    end
  end

  describe "GET 'ask_a_question'" do
    it "returns http success" do
      get :index
      response.should be_success
    end
  end

  describe "GET 'foi'" do
    it "returns http success" do
      get :index
      response.should be_success
    end
  end

  describe "GET 'general_feedback'" do
    it "returns http success" do
      get :index
      response.should be_success
    end
  end

  describe "GET 'i_cant_find'" do
    it "returns http success" do
      get :index
      response.should be_success
    end
  end

  describe "GET 'report_a_problem'" do
    it "returns http success" do
      get :index
      response.should be_success
    end
  end

end
