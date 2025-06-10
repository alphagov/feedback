GovukPublishingComponents.configure do |c|
  c.component_guide_title = "Email Alert Frontend Component Guide"
  c.application_stylesheet = "application"
  c.custom_css_exclude_list = %w[
    button
    cookie-banner
    heading
    input
    label
    layout-footer
    layout-for-public
    layout-super-navigation-header
    search
    search-with-autocomplete
    skip-link
  ]
end
