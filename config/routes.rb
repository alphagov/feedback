Rails.application.routes.draw do
  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response

  mount GovukPublishingComponents::Engine, at: "/component-guide"

  get "/contact", format: false, to: "contact#index"

  constraints FormatRoutingConstraint.new("completed_transaction") do
    get "*slug", slug: %r{done/register-flood-risk-exemption}, to: "assisted_digital_feedback#new"
    post "*slug", slug: %r{done/register-flood-risk-exemption}, to: "assisted_digital_feedback#create"
    get "*slug", slug: %r{done/waste-carrier-or-broker-registration}, to: "assisted_digital_feedback#new"
    post "*slug", slug: %r{done/waste-carrier-or-broker-registration}, to: "assisted_digital_feedback#create"
    get "*slug", slug: %r{done/register-waste-exemption}, to: "assisted_digital_feedback#new"
    post "*slug", slug: %r{done/register-waste-exemption}, to: "assisted_digital_feedback#create"

    get "*slug", slug: %r{done/.+}, to: "service_feedback#new"
    post "*slug", slug: %r{done/.+}, to: "service_feedback#create"
  end

  namespace :contact do
    get "govuk", to: "govuk#new", format: false
    post "govuk", to: "govuk#create", format: false

    get "govuk/anonymous-feedback/thankyou", to: "govuk#anonymous_feedback_thankyou", format: false, as: "anonymous_feedback_thankyou"
    get "govuk/thankyou", to: "govuk#named_contact_thankyou", format: false, as: "named_contact_thankyou"

    namespace :govuk do
      # This list of POST-able routes should be kept in sync with the rate-limited URLS in
      # govuk-puppet: https://github.com/alphagov/govuk-puppet/blob/master/modules/router/templates/router_include.conf.erb#L56-L61

      post "problem_reports", to: "problem_reports#create", format: false
      post "email-survey-signup", to: "email_survey_signup#create", format: false
      post "email-survey-signup.js", to: "email_survey_signup#create", defaults: { format: :js }
      post "content_improvement", to: "content_improvement#create", defaults: { format: :js }
      resources "page_improvements", only: [:create], format: false
      get "request-accessible-format", to: "accessible_format_requests#start_page", format: false
      get "request-accessible-format/format-type", to: "accessible_format_requests#format_type", format: false
      post "request-accessible-format/contact-details", to: "accessible_format_requests#contact_details", format: false
      post "request-accessible-format/send-request", to: "accessible_format_requests#send_request", format: false
      get "request-accessible-format/request-sent", to: "accessible_format_requests#request_sent", format: false
    end
  end

  root to: redirect("/contact")
end
