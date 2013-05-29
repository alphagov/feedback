class ZendeskConfig
  class << self
    def in_development_mode?
      details["development_mode"]
    end

    def fallback_requester_email_address
      email = details["fallback_requester_email_address"]
      raise ArgumentError, "No fallback email provided in zendesk.yml. This is needed 
        when the request is anonymous because Zendesk rejects tickets without an email address" if email.blank?
      email
    end

    def details
      @details ||= YAML.load_file(Rails.root.join('config', 'zendesk.yml'))
    end
  end
end