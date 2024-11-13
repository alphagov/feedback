class TicketCreator
  def initialize(ticket_params)
    @ticket_params = ticket_params
  end

  def send
    GdsApi.support_api.raise_support_ticket(payload)
  rescue GdsApi::HTTPUnprocessableEntity => e
    if e.error_details.dig("errors", "requester")&.include?("is suspended in Zendesk")
      Rails.logger.info("Support API skipped ticket creation because user is suspended")
    else
      raise e
    end
  end

  def payload
    {
      subject:,
      tags:,
      priority:,
      description: body,
      requester: ticket_params[:requester],
    }
  end

  def subject
    raise "Define subject in child class"
  end

  def body
    raise "Define body in child class"
  end

  def priority
    raise "Define priority in child class"
  end

  def tags
    raise "Define tags in child class"
  end

private

  attr_reader :ticket_params
end
