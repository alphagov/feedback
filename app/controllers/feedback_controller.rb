require 'ticket_client'

class FeedbackController < ApplicationController
  TICKET_PARAMS = %w(url what_doing what_wrong)

  before_filter :set_cache_control, :only => [:landing]

  def landing
  end

  def submit
    result = TicketClient.report_a_problem(params.select {|k,v| TICKET_PARAMS.include?(k) }.symbolize_keys)
    if result
      @message = "Thank you for your help."
      template = "thankyou"
    else
      @message = "Sorry, something went wrong."
      template = "something_went_wrong"
    end
    respond_to do |format|
      format.js { render :json => {"status" => (result ? "success" : "error"), "message" => @message} }
      format.html do
        extract_return_path(params[:url])
        render :action => template
      end
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
