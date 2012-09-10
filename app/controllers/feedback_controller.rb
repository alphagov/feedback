require 'ticket_client'

class FeedbackController < ApplicationController
  TICKET_PARAMS = %w(url what_doing what_wrong)

  before_filter :set_cache_control, :only => [:landing]

  def landing
  end

  def submit
    result = TicketClient.report_a_problem(params.select {|k,v| TICKET_PARAMS.include?(k) }.symbolize_keys)
    if result
      @message = "<p>Thank you for your help.</p> <p>If you have more extensive feedback, please visit the <a href='/feedback'>support page</a>.</p>".html_safe
    else
      @message = "<p>Sorry, we're unable to receive your message right now.</p> <p>We have other ways for you to provide feedback on the <a href='/feedback'>support page</a>.</p>".html_safe
    end
    respond_to do |format|
      format.js { render :json => {"status" => (result ? "success" : "error"), "message" => @message} }
      format.html do
        extract_return_path(params[:url])
        render :action => "thankyou"
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
