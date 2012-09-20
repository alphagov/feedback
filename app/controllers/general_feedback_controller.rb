require 'general_feedback_validator'

class GeneralFeedbackController < ApplicationController
  @@TITLE = "General Feedback"
  @@TAGS = ['general_feedback']
  @@HEADER = @@TITLE + @@MASTER_HEADER

  def index
    @header = @@HEADER
    @title = @@TITLE
    @departments = @@EMPTY_DEPARTMENT.merge @@ticket_client.get_departments
  end

  def submit
    validator = GeneralFeedbackValidator.new params
    @errors = validator.validate
    if @errors.empty?
      result = @@ticket_client.raise_ticket({
        subject: @@TITLE,
        tags: @@TAGS,
        name: params[:name],
        email: params[:email],
        department: params[:section],
        description: params[:feedback]});
        handle_done result
    else
      @header = @@HEADER
      @title = @@TITLE
      @old = params
      @departments = @@EMPTY_DEPARTMENT.merge @@ticket_client.get_departments
      render :action => "index"
    end
  end
end
