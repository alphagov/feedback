require "uri"

class WebSupportTicketCreator < TicketCreator
  def subject
    path = nil
    begin
      uri = URI.parse(ticket_params[:link])
      path = uri.path if uri.host == "www.gov.uk"
    rescue URI::InvalidURIError
      # If invalid URI provided by user, we'll just go with a general subject line
    end
    "Named contact#{path.present? ? " about #{path}" : ''}"
  end

  def body
    <<~MULTILINE_STRING
      [Requester]
      #{"#{ticket_params[:requester][:name]} <#{ticket_params[:requester][:email]}>"}

      [Details]
      #{ticket_params[:details]}

      [Link]
      #{ticket_params[:link]}

      [Referrer]
      #{ticket_params[:referrer].presence || 'Unknown'}

      [User agent]
      #{ticket_params[:user_agent].presence || 'Unknown'}

      [JavaScript Enabled]
      #{ticket_params[:javascript_enabled]}
    MULTILINE_STRING
  end

  def priority
    "normal"
  end

  def tags
    %w[public_form named_contact]
  end
end
