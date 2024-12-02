module ThrottlingManager
  extend ActiveSupport::Concern

  included do
    def decrement_throttle_counts
      if request.env["rack.attack.throttle_data"]
        request.env["rack.attack.throttle_data"].each do |name, values|
          decrement_throttle_count(name, values[:discriminator])
        end
      end
    end
  end

private

  def decrement_throttle_count(throttle_name, discriminator)
    last_epoch_time = Time.zone.now.to_i
    period = Rack::Attack.configuration.throttles[throttle_name].period
    key_name = [
      "rack::attack",
      (last_epoch_time / period).to_i,
      throttle_name,
      discriminator,
    ].join(":")

    Rack::Attack.cache.store.decrement(key_name, 1)
  end
end
