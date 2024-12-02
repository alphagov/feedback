require "rails_helper"

RSpec.describe ThrottlingManager do
  let(:controller) { ThrottlingTestController.new }
  let(:ip) { "192.168.1.1" }
  let(:period) { 60 }
  let(:key_name) do
    "requests by ip:#{ip}"
  end
  let(:cache) { Rack::Attack.cache }

  before do
    cache.write(key_name, 1, period)

    env = {
      "rack.attack.throttle_data" => {
        "requests by ip" => {
          discriminator: ip,
          count: 1,
          period: period,
          limit: 1,
          epoch_time: Time.zone.now.to_i,
        },
      },
    }

    allow(controller).to receive(:request) { ActionDispatch::Request.new(env) }
  end

  it "decrements rack::attack throttle count" do
    expect(cache.read(key_name)).to eq(1)

    controller.decrement_throttle_counts

    expect(cache.count(key_name, period)).to eq(0)
  end
end

class ThrottlingTestController < ApplicationController
  include ThrottlingManager
end
