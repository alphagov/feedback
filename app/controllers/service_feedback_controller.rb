class ServiceFeedbackController < ContactController
  include LocaleHelper
  # These 2 legacy completed transactions are linked to from multiple
  # transactions. The user satisfaction survey should not be shown for these as
  # it would generate noisy data for the linked organisation.
  LEGACY_BASE_PATHS = [
    "done/transaction-finished",
    "done/driving-transaction-finished",
  ].freeze

  layout "service_feedback"

  before_action :set_locale, if: -> { request.format.html? }

  def new
    @publication = helpers.publication
    @lang_attribute = lang_attribute(helpers.publication.locale.presence)

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
      GovukStatsd.increment("#{type}.successful_submission")

      respond_to_valid_submission(ticket)
    else
      GovukStatsd.increment("#{type}.invalid_submission")
      raise SpamError if ticket.spam?

      @errors = ticket.errors.to_hash
      @publication = helpers.publication
      @lang_attribute = lang_attribute(helpers.publication.locale.presence)

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
    ServiceFeedback
  end

  def type
    :service_feedback
  end

  def confirm_submission
    redirect_to contact_anonymous_feedback_thankyou_path
  end

  def show_survey?
    LEGACY_BASE_PATHS.exclude?(params[:base_path])
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
    @errors.each do |k, _v|
      instance_variable_set("@error_message_#{k}", @errors[k].first)
    end
  end

  def set_error_message_id_per_component
    # Set error message id vars to be used for linking to components from error summary
    @errors.each do |k, _v|
      instance_variable_set("@error_id_#{k}", "error-#{k}".gsub("_", "-"))
    end
  end
end
