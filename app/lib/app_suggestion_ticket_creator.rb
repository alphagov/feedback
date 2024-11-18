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
    NORMAL_PRIORTIY
  end

  def tags
    %w[govuk_app govuk_app_suggestion]
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
