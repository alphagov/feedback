class TicketClientDummy
  class << self

    def raise_ticket(zendesk)
      if zendesk[:description] =~ /break_zendesk/
        Rails.logger.info "Zendesk ticket creation fail for: #{zendesk.inspect}"
        nil
      else
        Rails.logger.info "Zendesk ticket created: #{zendesk.inspect}"
        zendesk
      end
    end

    def get_departments
      Rails.logger.info 'Zendesk get departments'
      {
        'Test Department One' => 'test_department_one',
        'Test Department Two' => 'test_department_two'
      }
    end

    def report_a_problem(zendesk)
      raise_ticket(zendesk)
    end
  end
end
