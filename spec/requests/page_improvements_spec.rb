require "rails_helper"
require "gds_api/test_helpers/support_api"

RSpec.describe "Page improvements", type: :request do
  include GdsApi::TestHelpers::SupportApi

  let(:common_headers) { { "Accept" => "application/json", "Content-Type" => "application/json" } }

  it "submits the feedback to the Support API" do
    stub_any_support_api_call

    post "/contact/govuk/page_improvements",
         params: {
           description: "The title is the wrong colour.",
           url: "https://gov.uk/path/to/page",
           name: "Henry",
           email: "henry@example.com",
           user_agent: "Safari",
         }.to_json,
         headers: common_headers

    expected_request = a_request(:post, Plek.current.find("support-api") + "/page-improvements")
      .with(body: {
        "description" => "The title is the wrong colour.",
        "url" => "https://gov.uk/path/to/page",
        "name" => "Henry",
        "email" => "henry@example.com",
        "user_agent" => "Safari",
      })

    expect(expected_request).to have_been_made
  end

  it "responds successfully" do
    params = { description: "The title is the wrong colour." }
    stub_support_api_create_page_improvement(params)

    post "/contact/govuk/page_improvements", params: params.to_json, headers: common_headers

    expect(response.code).to eq("201")
    expect(response_hash).to include("status" => "success")
  end

  context "when the Support API isn't available" do
    it "responds with an error" do
      support_api_isnt_available

      post "/contact/govuk/page_improvements",
           params: { description: "The title is the wrong colour." }.to_json,
           headers: common_headers

      assert_response :error
      expect(response_hash).to include("status" => "error")
    end
  end

  it "returns an error if the required attributes aren't supplied" do
    url = Plek.current.find("support-api") + "/page-improvements"
    stub_request(:post, url)
      .with(body: {}.to_json)
      .to_return(
        status: 422,
        body: { status: "error", errors: [{ description: "can't be blank" }] }.to_json,
        headers: { "Content-Type" => "application/json; charset=utf-8" },
      )

    post "/contact/govuk/page_improvements",
         params: {}.to_json,
         headers: common_headers

    expect(response.code).to eq("422")
    expect(response_hash).to include("status" => "error")
    expect(response_hash).to include("errors" => [{ "description" => "can't be blank" }])
  end

  it "only sends permitted attributes to the Support API" do
    stub_any_support_api_call

    post "/contact/govuk/page_improvements",
         params: {
           description: "The title is the wrong colour.",
           try_my_luck: "maliciousCode();",
         }.to_json,
         headers: common_headers

    expected_request = a_request(:post, Plek.current.find("support-api") + "/page-improvements")
      .with(body: { "description" => "The title is the wrong colour." })

    expect(expected_request).to have_been_made
  end

  def response_hash
    JSON.parse(response.body)
  end
end
