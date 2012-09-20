require 'ask_a_question_validator'

class AskAQuestionController < ApplicationController

  def index
    ticket_client = TicketClientConnection.get_client
    @departments = @@EMPTY_DEPARTMENT.merge ticket_client.get_departments
  end

  def submit
    validator = AskAQuestionValidator.new params
    @errors = validator.validate
    ticket_client = TicketClientConnection.get_client
    if @errors.empty?
      description = format_description params
      result = ticket_client.raise_ticket({
        subject: "Ask a Question",
        tags: ["ask_question"],
        name: params[:name],
        email: params[:email],
        department: params[:section],
        description: description});
        handle_done result
    else
      @old = params
      @departments = @@EMPTY_DEPARTMENT.merge ticket_client.get_departments
      render :action => "index"
    end
  end

  private

  def format_description(params)
    description = "[Question]\n" + params[:question]
    unless params[:searchterms].blank?
      description += "\n[Search Terms]\n" + params[:searchterms]
    end
    description
  end
end
