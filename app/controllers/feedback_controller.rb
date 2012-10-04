require 'ticket_client_connection'
require 'contact_validator'
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

  REASON_HASH = {
    "cant-find" => {:subject => "I can't find", :tag => "i_cant_find"},
    "ask-question" => {:subject => "Ask a question", :tag => "ask_question"},
    "report-problem" => {:subject => "Report a problem", :tag => "report_a_problem_public"},
    "make-suggestion" => {:subject => "General feedback", :tag => "general_feedback"}
  }

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
    validator = ContactValidator.new params
    @errors = validator.validate
    if @errors.empty?
      begin
        ticket = contact_ticket(params)
        ticket_client.raise_ticket(ticket)
        @message = DONE_OK_TEXT.html_safe
      rescue => e
        @message = DONE_NOT_OK_TEXT.html_safe
        ExceptionNotifier::Notifier.background_exception_notification(e).deliver
      end

      render "shared/thankyou"
    else
      @old = params
      @sections = ticket_client.get_sections
      render :action => "contact"
    end
  end

  def foi_submit
    validator = FoiValidator.new params
    @errors = validator.validate
    if @errors.empty?
      begin
        description = foi_ticket_description params
        ticket = {
          :subject => "FOI",
          :tags => ["FOI_request"],
          :name => params[:name],
          :email => params[:email],
          :description => description
        }
        ticket_client.raise_ticket(ticket)
        @message = DONE_OK_TEXT.html_safe
      rescue => e
        @message = DONE_NOT_OK_TEXT.html_safe
        ExceptionNotifier::Notifier.background_exception_notification(e).deliver
      end
      render "shared/thankyou"
    else
      @old = params
      render :action => "foi"
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

  def contact_ticket(params)
    ticket = {}
    if REASON_HASH[params["query-type"]]
      description = contact_ticket_description params
      subject = REASON_HASH[params["query-type"]][:subject]
      tag = REASON_HASH[params["query-type"]][:tag]
      ticket = {
        :subject => subject,
        :tags => [tag],
        :name => params[:name],
        :email => params[:email],
        :section => params[:section],
        :description => description
      }
    end
    ticket
  end

  def contact_ticket_description(params)
    description = "[Location]\n" + params[:location]
    if (params[:location] == "specific") and (not params[:link].blank?)
      description += "\n[Link]\n" + params[:link]
    end
    unless params[:name].blank?
      description += "\n[Name]\n" + params[:name]
    end

    unless params[:textdetails].blank?
      description += "\n[Details]\n" + params[:textdetails]
    end
    description
  end

  def foi_ticket_description(params)
    description = ""
    unless params[:name].blank?
      description += "[Name]\n" + params[:name] + "\n"
    end
    unless params[:textdetails].blank?
      description += "[Details]\n" + params[:textdetails]
    end
    description
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
