require "gds_api/publishing_api"

module AccessibleFormatHelper
  def attachment_title
    requested_attachment["title"]
  end

  def alternative_format_contact_email
    requested_attachment["alternative_format_contact_email"]
  end

  def content_path
    content_item["base_path"]
  end

  def accessible_format_options_to_radio_items(checked = nil)
    values = I18n.translate("models.accessible_format_options").map do |item|
      radio_item = item.dup
      radio_item.merge!(conditional: render_conditional(item)) if item[:conditional_label]
      radio_item.merge!(checked: true) if item[:value] == checked
      radio_item.except(:conditional_label, :conditional_name)
    end
    Rails.logger.info(values.to_s)
    values
  end

  def document_and_attachment_available?
    content_item && requested_attachment
  end

private

  def content_item
    @content_item ||= GdsApi.publishing_api.get_live_content(params[:content_id]).to_h
  end

  def requested_attachment
    content_attachments = content_item.dig("details", "attachments")
    attachment = content_attachments.find { |a| a["id"] == params[:attachment_id] }
    attachment || raise(Contact::Govuk::AccessibleFormatRequestsController::AttachmentNotFoundError)
  end

  def render_conditional(item)
    render("govuk_publishing_components/components/input", {
      id: item[:conditional_name],
      label: { text: item[:conditional_label] },
      name: item[:conditional_name],
      error_message: flash["#{item[:conditional_name]}_error".to_sym],
      value: params[item[:conditional_name]],
    })
  end
end
