require 'slimmer/headers'

class FeedbackController < ApplicationController
  include Slimmer::Headers
  DONE_OK_TEXT = "<p>Thank you for your help.</p> " +
    "<p>If you have more extensive feedback, " +
    "please visit the <a href='/feedback'>support page</a>.</p>"
  DONE_NOT_OK_TEXT = "<p>Sorry, we're unable to receive your message right now.</p> " +
    "<p>We have other ways for you to provide feedback on the " +
    "<a href='/feedback'>support page</a>.</p>"
  DONE_INVALID_TEXT = "<p>Sorry, we're unable to send your message as you haven't given us any information.</p> "+
    "<p>Please tell us what you were doing or what went wrong.</p>"

  before_filter :set_cache_control, :only => [
    :foi,
    :contact
  ]

  before_filter :get_sections, :only => [
    :contact,
    :contact_submit
  ]

  before_filter :setup_slimmer_artefact

  def contact_submit
    submit params[:contact].merge({:user_agent => (request.user_agent)}), :contact
  end

  def foi_submit
    submit params[:foi], :foi
  end

  def report_a_problem_submit
    attributes = params.merge(:user_agent => request.user_agent)

    # Where the 'url' parameter isn't explicitly provided, obtain it
    # from the HTTP referer. This is an edge case in the app as there
    # should only be a finite number of places where this occurs.
    # Specifially, the 40X pages on GOV.UK.
    attributes = attributes.merge(:url => request.referer) unless params.has_key? :url

    ticket = ReportAProblemTicket.new attributes

    respond_to do |format|
      if ticket.valid?
        if ticket.save
          @message = DONE_OK_TEXT.html_safe
          @status = 'success'
        else
          @message = DONE_NOT_OK_TEXT.html_safe
          @status = 'error'
        end
      else
        @status = 'invalid'
        @message = DONE_INVALID_TEXT.html_safe
        @errors = ticket.errors.full_messages
      end

      format.html do
        extract_return_path(params[:url])
        render "shared/thankyou"
      end
      format.js do
        response = { :message => @message, :status => @status }
        response[:errors] = @errors unless @errors.nil?

        render :json => response, :status => status_codes[@status]
      end
    end
  end

  private

  TICKET_HASH = {
    :contact => ContactTicket,
    :foi => FoiTicket
  }

  def submit(data, type)
    ticket = TICKET_HASH[type].new data

    if ticket.save
      @contact_provided = (not data[:email].blank?)
      render "shared/formok"
    else
      if ticket.errors[:connection] && ticket.errors[:connection].any?
        render "shared/formerror"
      elsif ticket.errors[:val] && ticket.errors[:val].any?
        val_error
      else
        @errors = ticket.errors.to_hash
        @old = data
        render :action => type
      end
    end
  end

  def get_sections
    @sections = ticket_client.get_sections
  end

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

  def status_codes
    {
      'success' => 201,
      'invalid' => 422,
      'error'   => 500
    }
  end

  def val_error
    render :nothing => true, :status => 444
  end
end
