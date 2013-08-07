require 'webmock'

module SupportAppStubs
  extend WebMock::API

  def assuming_successful_support_app_foi_request(name, email, details)
    stub_foi_request(name, email, details, 201)
  end

  def assuming_failed_support_app_foi_request(name, email, details)
    stub_foi_request(name, email, details, 503)
  end

  def stub_foi_request(name, email, details, status_code)
    stub_request(:post, /.*?\/foi_requests/).with(
      body: foi_request_params(name, email, details),
      headers: {'Accept'=>'application/json'}).
    to_return(status: status_code)
  end

  def foi_request_params(name, email, details)
    {"foi_request"=>{"requester"=>{"name"=>name, "email"=>email}, "details"=>details}}
  end
end

RSpec.configure do |config|
  config.include SupportAppStubs, :type => :request
end
