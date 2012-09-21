require 'spec_helper'

describe FeedbackController do

  describe "GET 'index'" do
    it "should set cache control headers for 10 mins" do
      get :index
      response.headers["Cache-Control"].should == "max-age=600, public"
      response.should be_success
    end
  end

  describe "GET 'ask_a_question'" do
    it "should set cache control headers for 10 mins" do
      get :ask_a_question
      response.headers["Cache-Control"].should == "max-age=600, public"
      response.should be_success
    end
  end

  describe "GET 'foi'" do
    it "should set cache control headers for 10 mins" do
      get :foi
      response.headers["Cache-Control"].should == "max-age=600, public"
      response.should be_success
    end
  end

  describe "GET 'general_feedback'" do
    it "should set cache control headers for 10 mins" do
      get :general_feedback
      response.headers["Cache-Control"].should == "max-age=600, public"
      response.should be_success
    end
  end

  describe "GET 'i_cant_find'" do
    it "should set cache control headers for 10 mins" do
      get :i_cant_find
      response.headers["Cache-Control"].should == "max-age=600, public"
      response.should be_success
    end
  end

  describe "GET 'report_a_problem'" do
    it "should set cache control headers for 10 mins" do
      get :report_a_problem
      response.headers["Cache-Control"].should == "max-age=600, public"
      response.should be_success
    end
  end

end
