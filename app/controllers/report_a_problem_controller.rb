require 'ticket_client_connection'
require 'report_a_problem_validator'

class ReportAProblemController < ApplicationController

  def submit
    validator = ReportAProblemValidator.new params
    @errors = validator.validate
    if @errors.empty?
      handle_submit(params)
    else
      @old = params
      render :action => "index"
    end
  end

  def submit_without_validation
    handle_submit params
  end

  def handle_submit(params)
    description = format_description params
    ticket_client = TicketClientConnection.get_client
    result = ticket_client.raise_ticket({
      subject: path_for_url(params[:url]),
      tags: ['report_a_problem'],
      description: description})
      handle_done result
  end

  private

  def path_for_url(url)
    uri = URI.parse(url)
    uri.path
  rescue URI::InvalidURIError
    "Unknown page"
  end

  def format_description(params)
    description = \
      "url: #{params[:url]}\n"\
    "what_doing: #{params[:what_doing]}\n"\
    "what_wrong: #{params[:what_wrong]}"
  end
end
