require 'i_cant_find_validator'

class ICantFindController < ApplicationController
  @@TITLE = "I Can't Find"
  @@TAGS = ['i_cant_find']
  @@LOOKING_FOR_TITLE = "[Looking For]"
  @@SEARCH_ITEMS_TITLE = "[Search Items]"
  @@HEADER = @@TITLE + @@MASTER_HEADER

  def index
    @header = @@HEADER
    @title = @@TITLE
    @departments = @@ticket_client.get_departments
  end

  def submit
    validator = ICantFindValidator.new params
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
      @departments = @@ticket_client.get_departments
      render :action => "index"
    end
  end

  def format_description(params)
    description = @@LOOKING_FOR_TITLE + "\n" + params[:lookingfor]
    unless params[:searchterms].blank?
      description += "\n" + @@SEARCH_ITEMS_TITLE + "\n" + params[:searchterms]
    end
    description
  end
end
