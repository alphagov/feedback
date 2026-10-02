module Metrics
  CLIENT = PrometheusExporter::Client.default
  GAUGES = {
    rate_limit_enabled: CLIENT.register(
      :gauge,
      "rate_limit_enabled",
      "Whether rate limiting is enabled (1) or disabled (0)",
    ),
  }.freeze
end
