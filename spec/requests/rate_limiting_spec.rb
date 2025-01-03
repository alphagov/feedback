require "rails_helper"
require "gds_api/test_helpers/support_api"

# Note - rate limit exemptions are tested in accessible_format_request_spec.rb

RSpec.describe "Rack::Attack Throttling of POSTs", type: :request do
  include GdsApi::TestHelpers::SupportApi

  let(:valid_params) do
    {
      contact: {
        name: "Joe Bloggs",
        email: "test@test.com",
        location: "all",
        textdetails: "Testing, testing, 1, 2, 3...",
      },
    }
  end

  before do
    Rack::Attack.enabled = true
    stub_any_support_api_call
  end

  after do
    Rack::Attack.enabled = false
  end

  context "by IP" do
    before do
      Rack::Attack.reset!
      allow_any_instance_of(Rack::Attack::Request).to receive(:ip).and_return("192.168.1.1")
      allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return("192.168.1.1")
    end

    it "doesn't throttle if manually decrementing throttle counts due to validation errors" do
      invalid_params = { contact: {} }
      post "/contact/govuk", params: invalid_params
      expect(response.status).to eq(200)
      3.times do |i|
        post "/contact/govuk", params: invalid_params.merge(contact: { email: "test#{i}@test.com" })
        expect(response.status).to eq(200)
      end
    end

    it "begins on the 2nd request from the same IP" do
      post "/contact/govuk", params: valid_params
      expect(response.status).to eq(302)
      3.times do |i|
        post "/contact/govuk", params: valid_params.merge(contact: { email: "test#{i}@test.com" })
        expect(response.status).to eq(429)
      end
    end

    it "still allows unthrottled IPs when throttling of another is active" do
      post "/contact/govuk", params: valid_params
      3.times do |i|
        post "/contact/govuk", params: valid_params.deep_merge(contact: { email: "test#{i}@test.com" })
      end

      allow_any_instance_of(Rack::Attack::Request).to receive(:ip).and_return("192.168.1.10")
      post "/contact/govuk", params: valid_params.deep_merge(contact: { email: "new.email@test.com" })
      expect(response.status).to eq(302)
    end

    context "With bypass token" do
      it "allows requests without throttling" do
        post "/contact/govuk", params: valid_params, headers: { "Rate-Limit-Token" => "bypass-please!" }
        expect(response.status).to eq(302)
        3.times do
          post "/contact/govuk", params: valid_params, headers: { "Rate-Limit-Token" => "bypass-please!" }
          expect(response.status).to eq(302)
        end
      end
    end
  end

  context "by provided email" do
    before do
      Rack::Attack.reset!
    end

    it "begins on the 2nd with the same email address" do
      post "/contact/govuk", params: valid_params
      expect(response.status).to eq(302)
      3.times do |i|
        allow_any_instance_of(Rack::Attack::Request).to receive(:ip).and_return("192.168.1.#{i}")
        post "/contact/govuk", params: valid_params
        expect(response.status).to eq(429)
      end
    end

    it "doesn't throttle if manually decrementing throttle counts due to validation errors" do
      invalid_params = { contact: { email: "example@example.com" } }
      post "/contact/govuk", params: invalid_params
      expect(response.status).to eq(200)
      3.times do |i|
        allow_any_instance_of(Rack::Attack::Request).to receive(:ip).and_return("192.168.1.#{i}")
        post "/contact/govuk", params: invalid_params
        expect(response.status).to eq(200)
      end
    end

    it "still allows unthrottled emails when throttling of another is active" do
      post "/contact/govuk", params: valid_params
      3.times do |i|
        allow_any_instance_of(Rack::Attack::Request).to receive(:ip).and_return("192.168.1.#{i}")
        post "/contact/govuk", params: valid_params
      end

      allow_any_instance_of(Rack::Attack::Request).to receive(:ip).and_return("192.168.1.10")
      post "/contact/govuk", params: valid_params.deep_merge(contact: { email: "new.email@test.com" })
      expect(response.status).to eq(302)
    end
  end
end
