module AccessibleFormatHelper
  def accessible_format_options_to_radio_items(checked = nil)
    values = I18n.translate("models.accessible_format_options").map do |item|
      radio_item = item.dup
      radio_item.merge!(conditional: render_conditional(item)) if item[:conditional_label]
      radio_item.delete(:conditional_label)
      radio_item.delete(:conditional_name)
      radio_item.merge!(checked: true) if item[:value] == checked
      radio_item
    end
    Rails.logger.info(values.to_s)
    values
  end

  def render_conditional(item)
    render("govuk_publishing_components/components/input", {
      label: { text: item[:conditional_label] },
      name: item[:conditional_name],
      error_message: flash["#{item[:conditional_name]}_error".to_sym],
      value: params[item[:conditional_name]],
    })
  end
end
