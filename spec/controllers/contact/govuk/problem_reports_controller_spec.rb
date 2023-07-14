require "rails_helper"

RSpec.describe Contact::Govuk::ProblemReportsController, type: :controller do
  render_views

  describe "POST" do
    context "with a valid report_a_problem submission" do
      context "html request" do
        def do_submit(attrs = {})
          post :create,
               params: {
                 url: "http://www.example.com/somewhere",
                 what_doing: "Nothing",
                 what_wrong: "Something",
               }.merge(attrs)
        end

        it "should save the ticket" do
          stub_ticket = double("Ticket")
          expect(ReportAProblemTicket).to receive(:new)
            .with(hash_including(
                    url: "http://www.example.com/somewhere",
                    what_doing: "Nothing",
                    what_wrong: "Something",
                    user_agent: "Rails Testing",
                  )).and_return(stub_ticket)
          expect(stub_ticket).to receive(:valid?).and_return(true)
          expect(stub_ticket).to receive(:save).and_return(true)

          do_submit
        end

        describe "assigning the return url" do
          it "should assign the return_url to the given url without the host etc." do
            do_submit
            expect(assigns[:return_path]).to eq("/somewhere")
          end

          it "should retain the query_string from the given URL" do
            do_submit url: "http://www.example.com/somewhere?foo=bar&baz=1"
            expect(assigns[:return_path]).to eq("/somewhere?foo=bar&baz=1")
          end

          it "should assign nil if an invalid url is provided" do
            do_submit url: "b[]laaaaaargh!"
            expect(assigns[:return_path]).to eq(nil)
          end

          it "should assign nil if no url is provided" do
            do_submit url: nil
            expect(assigns[:return_path]).to eq(nil)
          end
        end

        it "should render the thankyou template assigning the message string" do
          do_submit
          expect(response).to render_template("thankyou")
          expect(assigns[:message]).to eq("<h1 class='govuk-heading-l'>Thank you for your help.</h1> <p class='govuk-body'>If you have more extensive feedback, please visit the <a class='govuk-link' href='/contact'>contact page</a>.</p>")
          expect(assigns[:message]).to be_html_safe
        end

        context "when ticket creation fails" do
          before :each do
            allow_any_instance_of(ReportAProblemTicket).to receive(:save).and_raise(GdsApi::BaseError)
          end

          it "should render the thankyou template assigning the message string" do
            do_submit
            expect(response.response_code).to eq(503)
          end
        end

        describe "no 'url' value explicitly set" do
          it "should use the referrer URL to set the 'url' for the model" do
            stub_ticket = double("Ticket")
            expect(ReportAProblemTicket).to receive(:new)
              .with(hash_including(url: "http://www.gov.uk/referral-city"))
              .and_return(stub_ticket)
            expect(stub_ticket).to receive(:valid?).and_return(true)
            expect(stub_ticket).to receive(:save).and_return(true)

            @request.env["HTTP_REFERER"] = "http://www.gov.uk/referral-city"
            post :create,
                 params: {
                   what_doing: "Nothing",
                   what_wrong: "Something",
                 }
          end
        end
      end

      context "ajax submission" do
        def do_submit(attrs = {})
          post :create,
               params: {
                 url: "http://www.example.com/somewhere",
                 what_doing: "Nothing",
                 what_wrong: "Something",
                 javascript_enabled: "true",
                 referrer: "https://www.gov.uk/some-url/",
               }.merge(attrs),
               as: :json
        end

        it "should save the ticket" do
          stub_ticket = double("Ticket")
          expect(ReportAProblemTicket).to receive(:new)
            .with(hash_including(
                    url: "http://www.example.com/somewhere",
                    what_doing: "Nothing",
                    what_wrong: "Something",
                    user_agent: "Rails Testing",
                    javascript_enabled: "true",
                  )).and_return(stub_ticket)
          allow(stub_ticket).to receive(:valid?).and_return(true)
          expect(stub_ticket).to receive(:save).and_return(true)

          do_submit
        end

        it "should return json indicating success" do
          do_submit
          data = JSON.parse(response.body)
          expect(data).to eq("status" => "success", "message" => "<h1 class='govuk-heading-l'>Thank you for your help.</h1> <p class='govuk-body'>If you have more extensive feedback, please visit the <a class='govuk-link' href='/contact'>contact page</a>.</p>")
        end

        it "should return json indicating failure when ticket creation fails" do
          allow_any_instance_of(ReportAProblemTicket).to receive(:save).and_raise(GdsApi::BaseError)
          do_submit
          data = JSON.parse(response.body)
          expect(data).to eq("status" => "error", "message" => "<p>Sorry, we're unable to receive your message right now.</p> <p>We have other ways for you to provide feedback on the <a href='/contact'>contact page</a>.</p>")
        end
      end
    end
  end
end
