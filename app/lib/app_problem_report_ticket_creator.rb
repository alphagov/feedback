class AppProblemReportTicketCreator < TicketCreator
  def subject
    "Problem report"
  end

  def body
    <<~MULTILINE_STRING
      [Requester]
      #{requester_sentence}

      [Phone]
      #{ticket_params[:phone].presence || 'Not submitted'}

      [App version]
      #{ticket_params[:app_version].presence || 'Not submitted'}

      [What were you trying to do?]
      #{ticket_params[:trying_to_do]}

      [What happened?]
      #{ticket_params[:what_happened]}
    MULTILINE_STRING
  end

  def priority
    "high"
  end

  def tags
    %w[app_form]
  end

private

  def requester_sentence
    requester = ticket_params[:requester] || {}
    if requester[:name] && requester[:email]
      requester[:name] + " <#{requester[:email]}>"
    elsif requester[:email]
      requester[:email]
    else
      "Anonymous"
    end
  end
end
