class AppChatFeedbackTicketCreator < TicketCreator
  def subject
    "Leave feedback about GOV.UK Chat"
  end

  def body
    <<~MULTILINE_STRING
      [Requester]
      #{requester_sentence}

      [Please leave your feedback]
      #{ticket_params[:feedback]}
    MULTILINE_STRING
  end

  def priority
    NORMAL_PRIORTIY
  end

  def tags
    %w[govuk_app govuk_app_chat]
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
