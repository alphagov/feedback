require 'spec_helper'

describe Contact::Govuk::ProblemReportsController do

  before :each do
    ReportAProblemTicket.any_instance.stub(:save).and_return(true)
  end

  describe "POST" do
    context "with a valid report_a_problem submission" do
      context "html request" do
        def do_submit(attrs = {})
          post :create, {
            :url => "http://www.example.com/somewhere",
            :what_doing => "Nothing",
            :what_wrong => "Something",
          }.merge(attrs)
        end

        it "should save the ticket" do
          stub_ticket = double("Ticket")
          ReportAProblemTicket.should_receive(:new).
            with(hash_including(
              :url => "http://www.example.com/somewhere",
              :what_doing => "Nothing",
              :what_wrong => "Something",
              :user_agent => "Rails Testing"
            )).and_return(stub_ticket)
          stub_ticket.should_receive(:valid?).and_return(true)
          stub_ticket.should_receive(:save).and_return(true)

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

          it "should assign nil if an invalid url is provided" do
            do_submit :url => "b[]laaaaaargh!"
            assigns[:return_path].should == nil
          end

          it "should assign nil if no url is provided" do
            do_submit :url => nil
            assigns[:return_path].should == nil
          end
        end

        it "should render the thankyou template assigning the message string" do
          do_submit
          response.should render_template('thankyou')
          assigns[:message].should == "<h2>Thank you for your help.</h2> <p>If you have more extensive feedback, please visit the <a href='/contact'>contact page</a>.</p>"
          assigns[:message].should be_html_safe
        end

        context "when ticket creation fails" do
          before :each do
            ReportAProblemTicket.any_instance.stub(:save).and_raise(GdsApi::BaseError)
          end

          it "should render the thankyou template assigning the message string" do
            do_submit
            response.response_code.should == 503
          end
        end

        describe "no 'url' value explicitly set" do
          it "should use the referrer URL to set the 'url' for the model" do
            stub_ticket = double("Ticket")
            ReportAProblemTicket.should_receive(:new).
              with(hash_including(:url => "http://www.gov.uk/referral-city")).
              and_return(stub_ticket)
            stub_ticket.should_receive(:valid?).and_return(true)
            stub_ticket.should_receive(:save).and_return(true)

            @request.env["HTTP_REFERER"] = "http://www.gov.uk/referral-city"
            post :create, {
              :what_doing => "Nothing",
              :what_wrong => "Something",
            }
          end
        end
      end # html

      context "ajax submission" do
        def do_submit(attrs = {})
          xhr :post, :create, {
            :url => "http://www.example.com/somewhere",
            :what_doing => "Nothing",
            :what_wrong => "Something",
            :javascript_enabled => "true",
            :referrer => "https://www.gov.uk/some-url/"
          }.merge(attrs)
        end

        it "should save the ticket" do
          stub_ticket = double("Ticket")
          ReportAProblemTicket.should_receive(:new).
            with(hash_including(
              :url => "http://www.example.com/somewhere",
              :what_doing => "Nothing",
              :what_wrong => "Something",
              :user_agent => "Rails Testing",
              :javascript_enabled => "true"
            )).and_return(stub_ticket)
          stub_ticket.stub(:valid?).and_return(true)
          stub_ticket.should_receive(:save).and_return(true)

          do_submit
        end

        it "should return json indicating success" do
          do_submit
          data = JSON.parse(response.body)
          data.should == {"status" => "success", "message" => "<h2>Thank you for your help.</h2> <p>If you have more extensive feedback, please visit the <a href='/contact'>contact page</a>.</p>"}
        end

        it "should return json indicating failure when ticket creation fails"  do
          ReportAProblemTicket.any_instance.stub(:save).and_raise(GdsApi::BaseError)
          do_submit
          data = JSON.parse(response.body)
          data.should == {"status" => "error", "message" => "<p>Sorry, we're unable to receive your message right now.</p> <p>We have other ways for you to provide feedback on the <a href='/contact'>contact page</a>.</p>"}
        end
      end
    end
  end
end
