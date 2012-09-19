require 'foi_validator'

class FoiController < ApplicationController
  @@TITLE = "FOI"
  @@TAGS = ['FOI_request']
  @@HEADER = @@TITLE + @@MASTER_HEADER

  def index
    @header = @@HEADER
    @title = @@TITLE
  end

  def submit
    validator = FoiValidator.new params
    @errors = validator.validate
    if @errors.empty?
      result = @@ticket_client.raise_ticket({
        subject: @@TITLE,
        tags: @@TAGS,
        name: params[:name],
        email: params[:email],
        description: params[:foi]});
        handle_done result
    else
      @header = @@HEADER
      @title = @@TITLE
      @old = params
      render :action => "index"
    end
  end
end
