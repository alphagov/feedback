require 'ticket_client_connection'

class AskAQuestionController < ApplicationController
  @@ticket_client = TicketClientConnection.get_client
  @@QUESTION_TITLE = "[Question]"
  @@SEARCH_ITEMS_TITLE = "[Search Items]"

  def landing
    @departments = @@ticket_client.get_departments
  end

  def submit
    @errors = Validator.validate('ask_a_question', params)
    puts @errors
    if @errors.empty?
      description = format_description params
      result = @@ticket_client.raise_ticket({
        subject: "Ask a question",
        tags: ["ask_question"],
        name: params[:name],
        email: params[:email],
        department: params[:section],
        description: description});
        render :action => "thankyou"
    else
      @departments = @@ticket_client.get_departments
      render :action => "landing"
    end
  end

  private

  def validate_form(params)
  end

  class Validator
    @@required = { 'ask_a_question' => ['name', 'email']}

    def self.validate(form_name, params)
      errors = []
      errors = validate_required form_name, params, errors
    end

    def self.validate_required(form_name, params, errors)
      @@required[form_name].each do |key|
        if params[key].blank?
          errors << "#{key} is blank"
        end
      end
      errors
    end
  end

  def format_description(params)
    description = @@QUESTION_TITLE + "\n" + params[:question]
    unless params[:searchterms].blank?
      description += "\n" + @@SEARCH_ITEMS_TITLE + "\n" + params[:searchterms]
    end
    description
  end
end
