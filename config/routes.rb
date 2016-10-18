Feedback::Application.routes.draw do
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
      resources 'page_improvements', only: [:create], format: false
    end

    get 'look-for-jobs', to: redirect("https://jobsearch.direct.gov.uk/ContactUs.aspx")
  end

  root to: redirect("/contact")

  get "test_forms/report_a_problem" if Rails.env.development? || Rails.env.test?
end
