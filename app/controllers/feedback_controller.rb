require 'ticket_client_connection'
require 'foi_validator'
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
    ticket = ContactTicket.new params

    if ticket.save
      render "shared/formok"
    else
      if ticket.errors[:connection]
        render "shared/formerror"
      else
        @sections = ticket_client.get_sections
        @old = params
        @errors = ticket.errors
        render :action => "contact"
      end
    end
  end

  def foi_submit
    ticket = FoiTicket.new params

    if ticket.save
      render "shared/formok"
    else
      if ticket.errors[:connection]
        render "shared/formerror"
      else
        @sections = ticket_client.get_sections
        @old = params
        @errors = ticket.errors
        render :action => "foi"
      end
    end
  end

  def report_a_problem_submit
    result = 'success'
    @message = DONE_OK_TEXT.html_safe

    begin
      description = report_a_problem_format_description params
      ticket = {
        :subject => path_for_url(params[:url]),
        :tags => ['report_a_problem'],
        :description => description
      }
      ticket_client.raise_ticket(ticket)
    rescue => e
      @message = DONE_NOT_OK_TEXT.html_safe
      result = 'error'
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver
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

  def report_a_problem_format_description(params)
    description = "url: #{params[:url]}\n" +
    "what_doing: #{params[:what_doing]}\n" +
    "what_wrong: #{params[:what_wrong]}"
  end


  def path_for_url(url)
    uri = URI.parse(url)
    uri.path.presence || "Unknown page"
  rescue URI::InvalidURIError
    "Unknown page"
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
