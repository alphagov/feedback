module Metrics
  Rails.logger.info "**** FEEDBACK METRICS ****"
  CLIENT = PrometheusExporter::Client.default
  COUNTERS = {
    feedback_requests_total: CLIENT.register(
      :counter,
      "feedback_requests_total",
      "Total number of feedback requests",
    ),
  }.freeze
  HISTOGRAMS = {
    feedback_request_duration: CLIENT.register(
      :histogram,
      "feedback_request_duration",
      "Time taken to process a feedback request",
    ),
  }.freeze
end
