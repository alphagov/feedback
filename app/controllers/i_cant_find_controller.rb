require 'i_cant_find_validator'

class ICantFindController < ApplicationController

  def index
    ticket_client = TicketClientConnection.get_client
    @departments = @@EMPTY_DEPARTMENT.merge ticket_client.get_departments
  end

  def submit
    validator = ICantFindValidator.new params
    @errors = validator.validate
    ticket_client = TicketClientConnection.get_client
    if @errors.empty?
      description = format_description params
      result = ticket_client.raise_ticket({
        subject: "I can't find",
        tags: ["i_cant_find"],
        name: params[:name],
        email: params[:email],
        department: params[:section],
        description: description});
        handle_done result
    else
      @old = params
      ticket_client = TicketClientConnection.get_client
      @departments = @@EMPTY_DEPARTMENT.merge ticket_client.get_departments
      render :action => "index"
    end
  end

  def format_description(params)
    description = "[Looking For]\n" + params[:lookingfor]
    unless params[:link].blank?
      description += "\n[Link]\n" + params[:link]
    end
    unless params[:searchterms].blank?
      description += "\n[Search Terms]\n" + params[:searchterms]
    end
    description
  end
end
