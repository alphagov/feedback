class ContactController < ApplicationController
  include Slimmer::Headers
  include UTF8Cleaner

  before_filter :set_cache_control, only: [ :new ]
  before_filter :setup_slimmer_artefact, only: :new

  def new
    respond_to do |format|
      format.html do
        render :new
      end
      format.any do
        render nothing: true, status: 406
      end
    end
  end

  def create
    data = sanitised((contact_params || {}).merge(technical_attributes))
    ticket = ticket_class.new data

    if ticket.valid?
      ticket.save
      Statsd.new(::STATSD_HOST).increment("#{::STATSD_PREFIX}.#{type.to_s}.successful_submission")
      @contact_provided = (not data[:email].blank?)

      respond_to do |format|
        format.html do
          render "shared/formok"
        end
      end
    else
      Statsd.new(::STATSD_HOST).increment("#{::STATSD_PREFIX}.#{type.to_s}.invalid_submission")
      raise SpamError if ticket.spam?

      @errors = ticket.errors.to_hash
      @old = data

      respond_to do |format|
        format.html do
          render :new
        end
      end
    end
  end

  private
  def contact_params
    params[type]
  end

  private
  def set_cache_control
    expires_in 10.minutes, :public => true unless Rails.env.development?
  end

  def setup_slimmer_artefact
    set_slimmer_dummy_artefact(:section_name => "Contact", :section_link => "/contact")
  end

  def technical_attributes
    { user_agent: request.user_agent, varnish_id: request.env["HTTP_X_VARNISH"] }
  end
end
