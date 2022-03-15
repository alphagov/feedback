require "gds_api/publishing_api"

class Contact::Govuk::AccessibleFormatRequestsController < ContactController
  before_action :check_content_specified

  class AttachmentNotFoundError < StandardError; end

  rescue_from GdsApi::BaseError, with: :content_item_error
  rescue_from AttachmentNotFoundError, with: :content_item_error

  layout "accessible_format_requests"

  def start_page
    @back_path = helpers.content_path
  end

  def format_type
    @back_path = contact_govuk_request_accessible_format_path(
      content_id: params[:content_id],
      attachment_id: params[:attachment_id],
    )

    if params[:error] == "format-type-missing"
      flash.now[:input_errors] = [[I18n.t("controllers.contact.govuk.accessible_format_requests.format_type_error"), "format_type"]]
      flash.now[:format_type_error] = I18n.t("controllers.contact.govuk.accessible_format_requests.format_type_error")
    end

    if params[:error] == "other-format-missing"
      flash.now[:input_errors] = [[I18n.t("controllers.contact.govuk.accessible_format_requests.other_format_error"), "other_format"]]
      flash.now[:other_format_error] = I18n.t("controllers.contact.govuk.accessible_format_requests.other_format_error")
    end
  end

  def contact_details
    @back_path = contact_govuk_request_accessible_format_format_type_path(
      content_id: params[:content_id],
      attachment_id: params[:attachment_id],
      format_type: params[:format_type],
      other_format: params[:other_format],
    )

    if params[:format_type].blank?
      redirect_to(contact_govuk_request_accessible_format_format_type_path(content_id: params[:content_id], attachment_id: params[:attachment_id], error: "format-type-missing"))
    elsif params[:format_type] == "other" && params[:other_format].blank?
      redirect_to(contact_govuk_request_accessible_format_format_type_path(content_id: params[:content_id], attachment_id: params[:attachment_id], format_type: "other", error: "other-format-missing"))
    end
  end

  def send_request
    if params[:email_address].blank?
      flash.now[:input_errors] = [[I18n.t("controllers.contact.govuk.accessible_format_requests.email_missing_error"), "email_address"]]
      flash.now[:email_address_error] = I18n.t("controllers.contact.govuk.accessible_format_requests.email_missing_error")
      return render("contact_details")
    end

    unless ValidateEmail.valid?(params[:email_address])
      flash.now[:input_errors] = [[I18n.t("controllers.contact.govuk.accessible_format_requests.email_invalid_error"), "email_address"]]
      flash.now[:email_address_error] = I18n.t("controllers.contact.govuk.accessible_format_requests.email_invalid_error")
      return render("contact_details")
    end

    format_request = AccessibleFormatRequest.new(
      document_title: helpers.attachment_title,
      publication_path: helpers.content_path,
      format_type: params["format_type"],
      custom_details: params["other_format"],
      contact_name: params["full_name"],
      contact_email: params["email_address"],
      alternative_format_email: helpers.alternative_format_contact_email,
    )

    format_request.save

    redirect_to contact_govuk_request_accessible_format_request_sent_path(content_id: params[:content_id], attachment_id: params[:attachment_id])
  end

  def request_sent; end

private

  def check_content_specified
    slimmer_template(:gem_layout_no_feedback_form)
    render("missing_item") unless params[:content_id] && params[:attachment_id]
  end

  def content_item_error
    render("content_item_error")
  end
end
