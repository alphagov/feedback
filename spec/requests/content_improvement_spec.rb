require "rails_helper"
require "gds_api/test_helpers/support_api"

RSpec.describe "Content Improvement Feedback", type: :request do
  include GdsApi::TestHelpers::SupportApi

  let(:common_headers) { { "Accept" => "application/json", "Content-Type" => "application/json" } }
  let(:support_api_url) { Plek.current.find("support-api") }

  it "submits the feedback to the support api" do
    stub_any_support_api_call

    post "/contact/govuk/content_improvement",
         params: {
           description: "I need this page to exist",
         }.to_json,
         headers: common_headers

    expected_request = a_request(:post, support_api_url + "/anonymous-feedback/content_improvement")
      .with(body: {
              "description" => "I need this page to exist",
            })

    expect(expected_request).to have_been_made
  end

  it "responds successfully" do
    params = { description: "I need this page to exist" }
    stub_support_api_create_content_improvement_feedback(params)

    post "/contact/govuk/content_improvement", params: params.to_json, headers: common_headers

    expect(response.code).to eq("201")
    expect(response_hash).to include("status" => "success")
  end

  context "when the Support API isn't available" do
    it "responds with an error" do
      stub_support_api_isnt_available

      post "/contact/govuk/content_improvement",
           params: { description: "Huh?" }.to_json,
           headers: common_headers

      assert_response :error
      expect(response_hash).to include("status" => "error")
    end
  end

  it "returns an error if the required attributes aren't supplied" do
    url = support_api_url + "/anonymous-feedback/content_improvement"
    stub_http_request(:post, url)
      .with(body: {}.to_json)
      .to_return(
        status: 422,
        body: { status: "error", errors: [{ description: "can't be blank" }] }.to_json,
        headers: { "Content-Type" => "application/json; charset=utf-8" },
      )

    post "/contact/govuk/content_improvement",
         params: {}.to_json,
         headers: common_headers

    expect(response.code).to eq("422")
    expect(response_hash).to include("status" => "error")
    expect(response_hash).to include("errors" => [{ "description" => "can't be blank" }])
  end

  it "only sends permitted attributes to the Support API" do
    stub_any_support_api_call

    post "/contact/govuk/content_improvement",
         params: {
           description: "The title is the wrong colour.",
           another: "attribute",
         }.to_json,
         headers: common_headers

    expected_request = a_request(:post, Plek.current.find("support-api") + "/anonymous-feedback/content_improvement")
      .with(body: { "description" => "The title is the wrong colour." })

    expect(expected_request).to have_been_made
  end

  def stub_support_api_create_content_improvement_feedback(params)
    post_stub = stub_http_request(:post, "#{support_api_url}/anonymous-feedback/content_improvement")
    post_stub.with(body: params)
    post_stub.to_return(status: 201)
  end

  def response_hash
    JSON.parse(response.body)
  end
end
