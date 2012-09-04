require 'spec_helper'

describe FeedbackController do

  describe "GET 'landing'" do
    it "returns http success" do
      get :landing
      response.should be_success
    end
  end

  describe "POST 'submit'" do
    before :each do
      TicketClient.stub(:report_a_problem)
    end

    context "with a valid report_a_problem submission" do
      def do_submit(attrs = {})
        post :submit, {
          :url => "http://www.example.com/somewhere",
          :what_doing => "Nothing",
          :what_expected => "Something else",
          :what_happened => "Something",
        }.merge(attrs)
      end

      it "should submit a ticket to zendesk" do
        TicketClient.should_receive(:report_a_problem).with(
          :url => "http://www.example.com/somewhere",
          :what_doing => "Nothing",
          :what_happened => "Something",
          :what_expected => "Something else"
        )

        do_submit
      end

      it "should render the thankyou template" do
        do_submit
        response.should render_template('thankyou')
      end
    end
  end
end
