require 'foi_validator'

class FoiController < ApplicationController

  def submit
    validator = FoiValidator.new params
    @errors = validator.validate
    if @errors.empty?
      ticket_client = TicketClientConnection.get_client
      result = ticket_client.raise_ticket({
        subject: "FOI",
        tags: ["FOI_request"],
        name: params[:name],
        email: params[:email],
        description: params[:foi]});
        handle_done result
    else
      @old = params
      render :action => "index"
    end
  end
end
