require 'general_feedback_validator'

class GeneralFeedbackController < ApplicationController
  def index
    @departments = @@EMPTY_DEPARTMENT.merge ticket_client.get_departments
  end

  def submit
    validator = GeneralFeedbackValidator.new params
    @errors = validator.validate
    ticket_client = TicketClientConnection.get_client
    if @errors.empty?
      result = ticket_client.raise_ticket({
        subject: "General Feedback",
        tags: ["general_feedback"],
        name: params[:name],
        email: params[:email],
        department: params[:section],
        description: params[:feedback]});
        handle_done result
    else
      @old = params
      @departments = @@EMPTY_DEPARTMENT.merge ticket_client.get_departments
      render :action => "index"
    end
  end
end
