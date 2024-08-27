class AssistedDigitalFeedbackController < ContactController
  include LocaleHelper
  rescue_from GoogleSpreadsheetStore::Error, with: :unable_to_create_ticket_error

  before_action :set_locale, if: -> { request.format.html? }

  LEGACY_BASE_PATHS = [
    "done/transaction-finished",
    "done/driving-transaction-finished",
  ].freeze

  layout "service_feedback"

  def new
    @publication = helpers.publication

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
    data = contact_params.merge(browser_attributes)
    ticket = ticket_class.new data

    if ticket.valid?
      respond_to_valid_submission(ticket)
    else
      raise SpamError if ticket.spam?

      @errors = ticket.errors.to_hash
      @publication = helpers.publication

      handle_form_errors

      respond_to_invalid_submission(ticket)
    end
  end

private

  helper_method :show_survey?, :promotion

  def set_locale
    helpers.set_locale
  end

  def ticket_class
    MultiTicket.new(AssistedDigitalFeedback, ServiceFeedback)
  end

  def type
    :assisted_digital_feedback
  end

  def contact_params
    params[:service_feedback] || {}
  end

  def confirm_submission
    redirect_to contact_anonymous_feedback_thankyou_path
  end

  def show_survey?
    LEGACY_BASE_PATHS.exclude?(params[:slug])
  end

  def handle_form_errors
    set_form_field_values
    set_error_message_per_component
    set_error_message_id_per_component
  end

  def promotion
    @publication.promotion
  end

  def set_form_field_values
    # Set form values so that responses are not lost when the form reloads due to errors
    if params["service_feedback"].presence
      params["service_feedback"].each do |param|
        instance_variable_set("@value_#{param[0]}", param[1].presence)
      end
    end
  end

  def set_error_message_per_component
    # Set error message vars to be used to display errors above components
    @errors.each_key do |k|
      instance_variable_set("@error_message_#{k}", @errors[k].first)
    end
  end

  def set_error_message_id_per_component
    # Set error message id vars to be used for linking to components from error summary
    @errors.each_key do |k|
      instance_variable_set("@error_id_#{k}", "error-#{k}".gsub("_", "-"))
    end
  end
end
