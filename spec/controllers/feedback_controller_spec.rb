require 'spec_helper'

shared_examples_for "a contact resource" do
  context "on GET" do
    it "returns http success" do
      get resource_name
      response.should be_success
    end

    it "should set cache control headers for 10 mins" do
      get resource_name
      response.headers["Cache-Control"].should == "max-age=600, public"
      response.should be_success
    end

    it "should return 406 when text/html isn't acceptable" do
      request.env['HTTP_ACCEPT'] = 'nothing'
      get resource_name

      response.code.should eq("406")
    end

    it "should send a dummy artefact to slimmer with a Feedback section" do
      controller.should_receive(:set_slimmer_dummy_artefact).with(section_name: "Feedback", section_link: "/feedback")
      get resource_name
    end
  end

  context "on POST" do
    it "should return 406 when text/html isn't acceptable" do
      request.env['HTTP_ACCEPT'] = 'nothing'
      post resource_name, valid_params

      response.code.should eq("406")
    end
  end
end

describe FeedbackController do

  before :each do
    ReportAProblemTicket.any_instance.stub(:save).and_return(true)
  end

  describe "GET 'foi'" do
    let(:resource_name) { :foi }
    let(:valid_params) do
      { 
        foi: {
          name: "test name",
          email: "a@a.com",
          email_confirmation: "a@a.com",
          textdetails: "test foi"
        }
      }
    end

    it_behaves_like "a contact resource"
  end

  describe "GET 'contact'" do
    let(:resource_name) { :contact }
    let(:valid_params) do
      {
        contact: {
          name: "Joe Bloggs",
          email: "test@test.com",
          textdetails: "Testing, testing, 1, 2, 3...",
        }
      }
    end

    it_behaves_like "a contact resource"
  end

  describe "POST 'contact'" do
    context "with a valid contact submission" do
      def do_contact_submit(attrs = {})
        post :contact_submit, :contact => {
          :name => "Joe Bloggs",
          :email => "test@test.com",
          :textdetails => "Testing, testing, 1, 2, 3...",
        }.merge(attrs)
      end

      it "should respond successfully when POSTing a contact" do
        do_contact_submit
        response.should be_success
      end

      it "should create a ContactTicket object" do
        stub_ticket = double("Ticket", valid?: true)
        stub_ticket.should_receive(:save).and_return(true)

        ContactTicket.should_receive(:new).
          with(hash_including(
            :name => "Joe Bloggs",
            :email => "test@test.com",
            :textdetails => "Testing, testing, 1, 2, 3...",
          )).and_return(stub_ticket)

        do_contact_submit

        response.should be_success
      end
    end
  end

  describe "POST 'report_a_problem_submit'" do
    context "with a valid report_a_problem submission" do
      context "html request" do
        def do_submit(attrs = {})
          post :report_a_problem_submit, {
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
          assigns[:message].should == "<h2>Thank you for your help.</h2> <p>If you have more extensive feedback, please visit the <a href='/feedback'>support page</a>.</p>"
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
            post :report_a_problem_submit, {
              :what_doing => "Nothing",
              :what_wrong => "Something",
            }
          end
        end
      end # html

      context "ajax submission" do
        def do_submit(attrs = {})
          xhr :post, :report_a_problem_submit, {
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
          data.should == {"status" => "success", "message" => "<h2>Thank you for your help.</h2> <p>If you have more extensive feedback, please visit the <a href='/feedback'>support page</a>.</p>"}
        end

        it "should return json indicating failure when ticket creation fails"  do
          ReportAProblemTicket.any_instance.stub(:save).and_raise(GdsApi::BaseError)
          do_submit
          data = JSON.parse(response.body)
          data.should == {"status" => "error", "message" => "<p>Sorry, we're unable to receive your message right now.</p> <p>We have other ways for you to provide feedback on the <a href='/feedback'>support page</a>.</p>"}
        end
      end
    end
  end
end
