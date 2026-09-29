require "rails_helper"

RSpec.describe "Metrics" do
  let(:counter) { Metrics::COUNTERS[:rack_attack_throttled_requests_total] }
  it "registers Rack::Attack throttles requests counter" do
    expect(counter).not_to be_nil
  end

  it "increments the counter" do
    expect { counter.increment }.not_to raise_error
  end
end
