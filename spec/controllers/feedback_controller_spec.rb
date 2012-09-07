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
      context "html request" do
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

        it "should render the thankyou template assigning the message string" do
          do_submit
          response.should render_template('thankyou')
          assigns[:message].should == "Thank you for your help."
        end

        context "when ticket creation fails" do
          before :each do
            TicketClient.stub(:report_a_problem).and_return(false)
          end

          it "should render the something_went_wrong template assigning the message string" do
            do_submit
            response.should render_template('something_went_wrong')
            assigns[:message].should == "Sorry, something went wrong."
          end

          it "should still assign the return_path" do
            do_submit
            assigns[:return_path].should == "/somewhere"
          end
        end
      end # html

      context "ajax submission" do
        def do_submit(attrs = {})
          xhr :post, :submit, {
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

        it "should return json indicating success" do
          do_submit
          data = JSON.parse(response.body)
          data.should == {"status" => "success", "message" => "Thank you for your help."}
        end

        it "should return json indicating failure when ticket creation fails"  do
          TicketClient.stub(:report_a_problem).and_return(false)
          do_submit
          data = JSON.parse(response.body)
          data.should == {"status" => "error", "message" => "Sorry, something went wrong."}
        end
      end # AJAX
    end # valid report_a_problem
  end # POST 'submit'
end
