require 'slimmer/headers'

class ContactController < ApplicationController
  include Slimmer::Headers

  before_action :set_cache_control, only: [:new, :index]

  def index
    @popular_links = CONTACT_LINKS.popular
    @long_tail_links = CONTACT_LINKS.long_tail
    @breadcrumbs = [breadcrumbs.first]
  end

  def new
    @breadcrumbs = breadcrumbs

    respond_to do |format|
      format.html do
        render :new
      end
      format.any do
        head(:not_acceptable)
      end
    end
  end

  def create
    data = contact_params.merge(technical_attributes)
    ticket = ticket_class.new data

    if ticket.valid?
      Statsd.new(::STATSD_HOST).increment("#{::STATSD_PREFIX}.#{type}.successful_submission")
      @contact_provided = (not data[:email].blank?)

      respond_to_valid_submission(ticket)
    else
      Statsd.new(::STATSD_HOST).increment("#{::STATSD_PREFIX}.#{type}.invalid_submission")
      raise SpamError if ticket.spam?

      @errors = ticket.errors.to_hash
      @old = data

      respond_to_invalid_submission(ticket)
    end
  end

private

  def breadcrumbs
    [
      {
        title: "Home",
        url: '/'
      },
      {
        title: 'Contact',
        url: '/contact'
      }
    ]
  end

  def respond_to_valid_submission(ticket)
    ticket.save
    confirm_submission
  end

  def respond_to_invalid_submission(_ticket)
    rerender_form
  end

  def confirm_submission
    respond_to do |format|
      format.html do
        hide_report_a_problem_form_in_response
        if @contact_provided
          redirect_to contact_named_contact_thankyou_path
        else
          redirect_to contact_anonymous_feedback_thankyou_path
        end
      end
      format.any { head(:not_acceptable) }
    end
  end

  def rerender_form
    respond_to do |format|
      format.html do
        render :new
      end
    end
  end

  def contact_params
    params[type] || {}
  end

  def set_cache_control
    expires_in 10.minutes, public: true unless Rails.env.development?
  end

  def technical_attributes
    { user_agent: request.user_agent }
  end
end
