Rails.application.routes.draw do
  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response

  mount GovukPublishingComponents::Engine, at: "/component-guide"

  get "/contact", format: false, to: "contact#index"

  constraints FormatRoutingConstraint.new("completed_transaction") do
    get "*base_path", base_path: %r{done/register-flood-risk-exemption}, to: "assisted_digital_feedback#new"
    post "*base_path", base_path: %r{done/register-flood-risk-exemption}, to: "assisted_digital_feedback#create"
    get "*base_path", base_path: %r{done/waste-carrier-or-broker-registration}, to: "assisted_digital_feedback#new"
    post "*base_path", base_path: %r{done/waste-carrier-or-broker-registration}, to: "assisted_digital_feedback#create"
    get "*base_path", base_path: %r{done/register-waste-exemption}, to: "assisted_digital_feedback#new"
    post "*base_path", base_path: %r{done/register-waste-exemption}, to: "assisted_digital_feedback#create"

    get "*base_path", base_path: %r{done/.+}, to: "service_feedback#new"
    post "*base_path", base_path: %r{done/.+}, to: "service_feedback#create"
  end

  namespace :contact do
    get "govuk", to: "govuk#new", format: false
    post "govuk", to: "govuk#create", format: false

    get "govuk/anonymous-feedback/thankyou", to: "govuk#anonymous_feedback_thankyou", format: false, as: "anonymous_feedback_thankyou"
    get "govuk/thankyou", to: "govuk#named_contact_thankyou", format: false, as: "named_contact_thankyou"

    namespace :govuk do
      post "problem_reports", to: "problem_reports#create", format: false
      post "email-survey-signup", to: "email_survey_signup#create", format: false
      post "email-survey-signup.js", to: "email_survey_signup#create", defaults: { format: :js }
      post "content_improvement", to: "content_improvement#create", defaults: { format: :js }
      resources "page_improvements", only: [:create], format: false
    end
  end

  root to: redirect("/contact")
end
