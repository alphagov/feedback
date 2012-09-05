require 'ticket_client'

class FeedbackController < ApplicationController
  TICKET_PARAMS = %w(url what_doing what_happened what_expected)

  before_filter :set_cache_control, :only => [:landing]

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

  def set_cache_control
    expires_in 10.minutes, :public => true unless Rails.env.development?
  end

  def extract_return_path(url)
    uri = URI.parse(url)
    @return_path = uri.path
    @return_path << "?#{uri.query}" if uri.query.present?
    @return_path
  rescue URI::InvalidURIError
  end
end
