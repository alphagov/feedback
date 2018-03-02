Rails.application.routes.draw do
  mount GovukPublishingComponents::Engine, at: "/component-guide"

  get "/contact", format: false, to: "contact#index"

  namespace :contact do
    get 'govuk', to: "govuk#new", format: false
    post 'govuk', to: "govuk#create", format: false

    get 'govuk/anonymous-feedback/thankyou', to: "govuk#anonymous_feedback_thankyou", format: false, as: "anonymous_feedback_thankyou"
    get 'govuk/thankyou', to: "govuk#named_contact_thankyou", format: false, as: "named_contact_thankyou"

    get 'foi', to: "foi#new", format: false
    post 'foi', to: "foi#create", format: false

    namespace :govuk do
      post 'problem_reports', to: "problem_reports#create", format: false
      post 'service-feedback', to: "service_feedback#create", format: false
      post 'assisted-digital-survey-feedback', to: "assisted_digital_feedback#create", format: false
      post 'email-survey-signup', to: 'email_survey_signup#create', format: false
      post 'email-survey-signup.js', to: 'email_survey_signup#create', defaults: { format: :js }
      resources 'page_improvements', only: [:create], format: false
    end

    get 'look-for-jobs', to: redirect("https://jobsearch.direct.gov.uk/ContactUs.aspx")
  end

  root to: redirect("/contact")
end
