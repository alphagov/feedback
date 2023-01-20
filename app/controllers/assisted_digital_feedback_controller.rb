class AssistedDigitalFeedbackController < ContactController
  rescue_from GoogleSpreadsheetStore::Error, with: :unable_to_create_ticket_error
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
      GovukStatsd.increment("#{type}.successful_submission")

      respond_to_valid_submission(ticket)
    else
      GovukStatsd.increment("#{type}.invalid_submission")
      raise SpamError if ticket.spam?

      @errors = ticket.errors.to_hash
      @publication = helpers.publication
      set_form_field_values
      set_error_message_per_component
      set_error_message_id_per_component

      respond_to_invalid_submission(ticket)
    end
  end
private
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
