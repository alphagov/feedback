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

  describe "POST 'submit'" do
    before :each do
      TicketClient.stub(:report_a_problem).and_return(true)
    end

    context "with a valid report_a_problem submission" do
      def do_submit(attrs = {})
        post :submit, {
          :url => "http://www.example.com/somewhere",
          :what_doing => "Nothing",
          :what_wrong => "Something",
        }.merge(attrs)
      end

      it "should submit a ticket to zendesk" do
        TicketClient.should_receive(:report_a_problem).with(
          :url => "http://www.example.com/somewhere",
          :what_doing => "Nothing",
          :what_wrong => "Something"
        )

        do_submit
      end

      describe "assigning the return url" do
        it "should assign the return_url to the given url without the host etc." do
          do_submit
          assigns[:return_path].should == "/somewhere"
        end

        it "should retain the query_string from the given URL" do
          do_submit :url => "http://www.example.com/somewhere?foo=bar&baz=1"
          assigns[:return_path].should == "/somewhere?foo=bar&baz=1"
        end

        it "should assign nil if no url is provided" do
          do_submit :url => nil
          assigns[:return_path].should == nil
        end
      end

      it "should render the thankyou template" do
        do_submit
        response.should render_template('thankyou')
      end

      context "when ticket creation fails" do
        before :each do
          TicketClient.stub(:report_a_problem).and_return(false)
        end

        it "should render the something_went_wrong template" do
          do_submit
          response.should render_template('something_went_wrong')
        end

        it "should still assign the return_path" do
          do_submit
          assigns[:return_path].should == "/somewhere"
        end
      end
    end
  end # POST 'submit'
end
