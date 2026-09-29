module Metrics
  CLIENT = PrometheusExporter::Client.default
  COUNTERS = {
    rack_attack_throttled_requests_total: CLIENT.register(
      :counter,
      "rack_attack_throttled_requests_total",
      "Number of requests throttled by Rack::Attack",
    ),
  }.freeze
end
