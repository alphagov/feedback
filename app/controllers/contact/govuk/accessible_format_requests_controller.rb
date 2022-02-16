require "gds_api/publishing_api"

class Contact::Govuk::AccessibleFormatRequestsController < ContactController
  helper_method :attachment_title
  helper_method :content_path
  before_action :check_content_specified

  rescue_from GdsApi::BaseError, with: :content_item_error
  rescue_from AttachmentNotFoundError, with: :content_item_error

  layout "accessible_format_requests"

  def format_type
    @back_path = content_path
  end

  def contact_details
    if params[:format_type].blank?
      flash[:input_errors] = [I18n.t("controllers.contact.govuk.accessible_format_requests.format_type_error")]
      flash[:format_type_error] = I18n.t("controllers.contact.govuk.accessible_format_requests.format_type_error")
      redirect_to(contact_govuk_request_accessible_format_path(content_id: params[:content_id], attachment_id: params[:attachment_id]))
    end

    if params[:format_type] == "other" && params[:other_format].blank?
      flash[:input_errors] = [I18n.t("controllers.contact.govuk.accessible_format_requests.other_format_error")]
      flash[:other_format_error] = I18n.t("controllers.contact.govuk.accessible_format_requests.other_format_error")
      redirect_to(contact_govuk_request_accessible_format_path(content_id: params[:content_id], attachment_id: params[:attachment_id], format_type: "other"))
    end

    @back_path = contact_govuk_request_accessible_format_path(
      content_id: params[:content_id],
      attachment_id: params[:attachment_id],
      format_type: params[:format_type],
      other_format: params[:other_format],
    )
  end

  def send_request
    if params[:email_address].blank?
      flash.now[:input_errors] = [I18n.t("controllers.contact.govuk.accessible_format_requests.email_missing_error")]
      flash.now[:email_address_error] = I18n.t("controllers.contact.govuk.accessible_format_requests.email_missing_error")
      return render("contact_details")
    end

    unless ValidateEmail.valid?(params[:email_address])
      flash.now[:input_errors] = [I18n.t("controllers.contact.govuk.accessible_format_requests.email_invalid_error")]
      flash.now[:email_address_error] = I18n.t("controllers.contact.govuk.accessible_format_requests.email_invalid_error")
      return render("contact_details")
    end

    format_request = AccessibleFormatRequest.new(
      document_title: requested_attachment["title"],
      publication_path: content_path,
      format_type: params["format_type"],
      custom_details: params["other_format"],
      contact_name: params["full_name"],
      contact_email: params["email_address"],
      alternative_format_email: requested_attachment["alternative_format_contact_email"],
    )

    format_request.save

    redirect_to contact_govuk_request_accessible_format_request_sent_path(content_id: params[:content_id], attachment_id: params[:attachment_id])
  end

  def request_sent; end

  def attachment_title
    requested_attachment["title"]
  end

  def content_path
    content_item["base_path"]
  end

  def permitted_params
    params.permit(:content_id, :attachment_id, :format_type, :other_format, :email_address, :full_name)
  end

private

  def check_content_specified
    slimmer_template(:gem_layout_no_feedback_form)
    render("missing_item") unless params[:content_id] && params[:attachment_id]
  end

  def content_item
    @content_item ||= GdsApi.publishing_api.get_content(params[:content_id]).to_h
  end

  def content_attachments
    content_item.dig("details", "attachments")
  end

  def requested_attachment
    @requested_attachment ||= content_attachments.find { |a| a["id"] == params[:attachment_id] }
  end
end
