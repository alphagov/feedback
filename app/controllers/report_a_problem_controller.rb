require 'ticket_client_connection'
require 'report_a_problem_validator'

class ReportAProblemController < ApplicationController
  @@ticket_client = TicketClientConnection.get_client
  @@TAGS = ['report_a_problem']
  @@TITLE = 'Report a Problem'
  @@HEADER = @@TITLE + @@MASTER_HEADER

  def index
    @header = @@HEADER
    @title = @@TITLE
  end

  def submit
    validator = ReportAProblemValidator.new params
    @errors = validator.validate
    if @errors.empty?
      submit_without_validation(params)
    else
      @title = @@TITLE
      @header = @@HEADER
      @old = params
      render :action => "index"
    end
  end

  def submit_without_validation
    description = format_description params
    client = TicketClientConnection.get_client
    result = @@ticket_client.raise_ticket({
      subject: path_for_url(params[:url]),
      tags: @@TAGS,
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
    "what_doing: #{params[:what_doing]}"\
    "what_wrong: #{params[:what_wrong]}"
  end
end
