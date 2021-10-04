require "notify_service"

api_key = if Rails.env.test?
            # This is not a valid key, but it has the right form so the client
            # won't break when interrogating it
            "testkey1-12345678-90ab-cdef-1234-567890abcdef-12345678-90ab-cdef-1234-567890abcdef"
          else
            ENV["GOVUK_NOTIFY_API_KEY"]
          end

Rails.application.config.notify_service = NotifyService.new(api_key)
