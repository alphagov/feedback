class TicketClientDummy
  class << self

    def raise_ticket(zendesk)
      if zendesk[:description] =~ /break_zendesk/
        Rails.logger.info "Zendesk ticket creation fail for: #{zendesk.inspect}"
        raise StandardError
      else
        Rails.logger.info "Zendesk ticket created: #{zendesk.inspect}"
        zendesk
      end
    end

    def get_sections
      Rails.logger.info 'Zendesk get sections'
      {
        'Test Section One' => 'test_section_one',
        'Test Section Two' => 'test_section_two'
      }
    end
  end
end
