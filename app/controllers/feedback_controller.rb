require 'slimmer/headers'

class FeedbackController < ApplicationController
  include Slimmer::Headers
  DONE_OK_TEXT = "<p>Thank you for your help.</p> " +
    "<p>If you have more extensive feedback, " +
    "please visit the <a href='/feedback'>support page</a>.</p>"
  DONE_NOT_OK_TEXT = "<p>Sorry, we're unable to receive your message right now.</p> " +
    "<p>We have other ways for you to provide feedback on the " +
    "<a href='/feedback'>support page</a>.</p>"

  before_filter :set_cache_control, :only => [
    :foi,
    :report_a_problem_submit,
    :contact
  ]

  before_filter :setup_slimmer_artefact

  def contact
    @sections = ticket_client.get_sections
  end

  def contact_submit
    ticket = ContactTicket.new params[:contact]

    if ticket.save
      render "shared/formok"
    else
      if ticket.errors.has_key? :connection
        render "shared/formerror"
      else
        @errors = ticket.errors.to_hash
        @sections = ticket_client.get_sections
        @old = params[:contact]
        render :action => "contact"
      end
    end
  end

  def foi_submit
    ticket = FoiTicket.new params

    if ticket.save
      render "shared/formok"
    else
      if ticket.errors.has_key? :connection
        render "shared/formerror"
      else
        @errors = ticket.errors.to_hash
        @sections = ticket_client.get_sections
        @old = params
        render :action => "foi"
      end
    end
  end

  def report_a_problem_submit
    ticket = ReportAProblemTicket.new params
    result = 'success'
    @message = DONE_OK_TEXT.html_safe

    unless ticket.save
      result = 'error'
      @message = DONE_NOT_OK_TEXT.html_safe
    end

    respond_to do |format|
      format.js do
        render :json => {
          "status" => result,
          "message" => @message
        }
      end
      format.html do
        extract_return_path(params[:url])
        render "shared/thankyou"
      end
    end
  end

  private

  def ticket_client
    @ticket_client ||= TicketClientConnection.get_client
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

  def setup_slimmer_artefact
    set_slimmer_dummy_artefact(:section_name => "Feedback", :section_link => "/feedback")
  end

end
