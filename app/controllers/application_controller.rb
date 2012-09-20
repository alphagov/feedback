require 'ticket_client_connection'

class ApplicationController < ActionController::Base
  @@ticket_client = TicketClientConnection.get_client
  @@MASTER_HEADER = " | Help | GOV.UK"
  @@TITLE = " Feedback"
  @@DONE_OK_TEXT = \
    "<p>Thank you for your help.</p> "\
    "<p>If you have more extensive feedback, "\
    "please visit the <a href='/feedback'>support page</a>.</p>"
  @@DONE_NOT_OK_TEX = \
    "<p>Sorry, we're unable to receive your message right now.</p> "\
    "<p>We have other ways for you to provide feedback on the "\
    "<a href='/feedback'>support page</a>.</p>"

  @@EMPTY_DEPARTMENT = {"Select Department" => ""}

  before_filter :set_cache_control, :only => [:landing]

  private

  def handle_done(result)
    if result
      @message = @@DONE_OK_TEXT.html_safe
    else
      @message = @@DONE_NOT_OK_TEXT.html_safe
    end
    respond_to do |format|
      format.js do
        render :json => {
          "status" => (result ? "success" : "error"),
          "message" => @message
        }
      end
      format.html do
        extract_return_path(params[:url])
        render "shared/thankyou"
      end
    end
  end

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
