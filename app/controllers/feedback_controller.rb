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

  before_filter :get_sections, :only => [
    :contact,
    :contact_submit
  ]

  before_filter :setup_slimmer_artefact

  def contact_submit
    submit params, :contact
  end

  def foi_submit
    submit params, :foi
  end

  def report_a_problem_submit
    ticket = ReportAProblemTicket.new params.merge(:user_agent => request.user_agent)

    if ticket.save
      result = 'success'
      @message = DONE_OK_TEXT.html_safe
    else
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

  TICKET_HASH = {
    :contact => ContactTicket,
    :foi => FoiTicket
  }

  def submit(params, type)
    data = params[type]
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

  def val_error
    render :nothing => true, :status => 444
  end
end
