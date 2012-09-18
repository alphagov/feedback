require 'ticket_client_connection'

class AskAQuestionController < ApplicationController
  @@ticket_client = TicketClientConnection.get_client
  @@QUESTION_TITLE = "[Question]"
  @@SEARCH_ITEMS_TITLE = "[Search Items]"

  def landing
    @departments = @@ticket_client.get_departments
  end

  def submit
    description = format_description params
    result = @@ticket_client.raise_ticket({
      subject: "Ask a question",
      tags: ["ask_question"],
      name: params[:name],
      email: params[:email],
      department: params[:section],
      description: description});
      render :action => "thankyou"
  end

  private

  def format_description(params)
    description = @@QUESTION_TITLE + "\n" + params[:question]
    unless params[:searchterms].blank?
      description += "\n" + @@SEARCH_ITEMS_TITLE + "\n" + params[:searchterms]
    end
    description
  end

end
