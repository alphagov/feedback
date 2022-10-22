require "redis/client"

class Redis
  class Client
    def call(*_command, **_kwargs)
      # rubocop:disable Rails/Exit
      # rubocop:disable Rails/Output
      puts caller
      exit
      # rubocop:enable Rails/Output
      # rubocop:enable Rails/Exit
    end
  end
end
