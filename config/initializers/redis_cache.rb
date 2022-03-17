# Setup redis cache for Rack::Attack

Rails.application.config.cache_store =
  :redis_store,
  {
    url: ENV["REDIS_URL"],
    connect_timeout: 30,
    read_timeout: 0.2,
    write_timeout: 0.2,
    reconnect_attempts: 1,
  }
