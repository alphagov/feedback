require 'ask_a_question_validator'

class AskAQuestionController < ApplicationController
  @@TITLE = "Ask a Question"
  @@TAGS = ['ask_question']
  @@QUESTION_TITLE = "[Question]"
  @@SEARCH_ITEMS_TITLE = "[Search Items]"
  @@HEADER = @@TITLE + @@MASTER_HEADER

  def index
    @title = @@TITLE
    @header = @@HEADER
    @departments = @@EMPTY_DEPARTMENT.merge @@ticket_client.get_departments
  end

  def submit
    validator = AskAQuestionValidator.new params
    @errors = validator.validate
    if @errors.empty?
      description = format_description params
      result = @@ticket_client.raise_ticket({
        subject: @@TITLE,
        tags: @@TAGS,
        name: params[:name],
        email: params[:email],
        department: params[:section],
        description: description});
        handle_done result
    else
      @header = @@HEADER
      @title = @@TITLE
      @old = params
      @departments = @@EMPTY_DEPARTMENT.merge @@ticket_client.get_departments
      render :action => "index"
    end
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
