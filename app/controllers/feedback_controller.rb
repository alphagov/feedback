require 'ticket_client'

class FeedbackController < ApplicationController
  TICKET_PARAMS = %w(url what_doing what_happened what_expected)

  def landing
  end

  def submit
    extract_return_path(params[:url])
    if TicketClient.report_a_problem(params.select {|k,v| TICKET_PARAMS.include?(k) }.symbolize_keys)
      render :action => 'thankyou'
    else
      render :action => 'something_went_wrong'
    end
  end

  private

  def extract_return_path(url)
    uri = URI.parse(url)
    @return_path = uri.path
    @return_path << "?#{uri.query}" if uri.query.present?
    @return_path
  rescue URI::InvalidURIError
  end
end
