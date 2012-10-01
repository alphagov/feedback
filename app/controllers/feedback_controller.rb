require 'ticket_client_connection'
require 'contact_validator'
require 'foi_validator'
require 'true_validator'
require 'exception_mailer'
require 'slimmer/headers'

class FeedbackController < ApplicationController
  include Slimmer::Headers
  DONE_OK_TEXT = \
    "<p>Thank you for your help.</p> "\
    "<p>If you have more extensive feedback, "\
    "please visit the <a href='/feedback'>support page</a>.</p>"
  DONE_NOT_OK_TEXT = \
    "<p>Sorry, we're unable to receive your message right now.</p> "\
    "<p>We have other ways for you to provide feedback on the "\
    "<a href='/feedback'>support page</a>.</p>"

  REASON_HASH = {
      "cant-find" => {:subject => "I can't find", :tag => "i_cant_find"},
      "ask-question" => {:subject => "Ask a question", :tag => "ask_question"},
      "report-problem" => {:subject => "Report a problem", :tag => "report_a_problem"},
      "make-suggestion" => {:subject => "General feedback", :tag => "general_feedback"}
  }

  before_filter :set_cache_control, :only => [
    :foi,
    :report_a_problem_submit_without_validation,
    :contact
  ]

  before_filter :setup_slimmer_artefact

  def contact
    @ticket_client = TicketClientConnection.get_client
    @sections = @ticket_client.get_sections
  end

  def contact_submit
    @ticket_client = TicketClientConnection.get_client
    ticket = create_ticket(params)
    submit(ContactValidator, ticket, "contact")
  end

  def foi
    @ticket_client = TicketClientConnection.get_client
  end

  def foi_submit
    @ticket_client = TicketClientConnection.get_client

    description = ""
    unless params[:name].blank?
      description += "[Name]\n" + params[:name] + "\n"
    end

    unless params[:textdetails].blank?
      description += "[Details]\n" + params[:textdetails]
    end

    ticket = {
        :subject => "FOI",
        :tags => ["FOI_request"],
        :name => params[:name],
        :email => params[:email],
        :description => description}
    submit(FoiValidator, ticket, "foi")
  end

  def report_a_problem_submit_without_validation
    @ticket_client = TicketClientConnection.get_client
    @return_path = params[:url]
    description = report_a_problem_format_description params
    submit(TrueValidator, {
        subject: path_for_url(params[:url]),
        tags: ['report_a_problem'],
        description: description}, "report_a_problem")
  end

  private

  def submit(validator_class, ticket, action)
    validator = validator_class.new params
    @errors = validator.validate
    result = 'success'
    if @errors.empty? and (not ticket.empty?)
      begin
        @ticket_client.raise_ticket(ticket);
        @message = DONE_OK_TEXT.html_safe
      rescue
        @message = DONE_NOT_OK_TEXT.html_safe
        result = 'error'
        ExceptionMailer.deliver_exception_notification("Feedback: error creating ticket. Please refer to log.")
      end

      respond_to do |format|
        format.js do
          render :json => {
              "status" => (result),
              "message" => @message
          }
        end
        format.html do
          extract_return_path(params[:url])
          render "shared/thankyou"
        end
      end

    else
      @old = params
      @sections = @ticket_client.get_sections
      render :action => action
    end
  end

  def create_ticket(params)
    ticket = {}
    if REASON_HASH[params["query-type"]]
      description = ticket_description params
      subject = REASON_HASH[params["query-type"]][:subject]
      tag = REASON_HASH[params["query-type"]][:tag]
      ticket = {
        :subject => subject,
        :tags => [tag],
        :name => params[:name],
        :email => params[:email],
        :section => params[:section],
        :description => description}
    end
    ticket
  end

  def ticket_description(params)
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

  def report_a_problem_format_description(params)
    description = \
      "url: #{params[:url]}\n"\
    "what_doing: #{params[:what_doing]}\n"\
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
