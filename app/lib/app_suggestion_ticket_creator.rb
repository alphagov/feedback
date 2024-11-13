class AppSuggestionTicketCreator < TicketCreator
  def subject
    "Suggestion"
  end

  def body
    <<~MULTILINE_STRING
      [Requester]
      #{requester_sentence}

      [What is your suggestion?]
      #{ticket_params[:details]}
    MULTILINE_STRING
  end

  def priority
    "medium"
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
