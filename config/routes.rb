Feedback::Application.routes.draw do
  get "/contact", format: false, to: "contact#index"

  namespace :contact do
    get 'govuk', to: "govuk#new", format: false
    post 'govuk', to: "govuk#create", format: false

    get 'foi', to: "foi#new", format: false
    post 'foi', to: "foi#create", format: false

    namespace :govuk do
      post 'problem_reports', to: "problem_reports#create", format: false
      post 'service-feedback', to: "service_feedback#create", format: false
    end

    get 'dvla', to: redirect("/contact-the-dvla")
    get 'look-for-jobs', to: redirect("https://jobsearch.direct.gov.uk/ContactUs.aspx")
    get 'passport-advice-line', to: redirect("/passport-advice-line")
    get 'student-finance-england', to: redirect("/contact-student-finance-england")
    get 'jobcentre-plus', to: redirect("/contact-jobcentre-plus")
  end

  # these are deprecated routes that can be removed once all frontends are submitting to the /contact endpoints
  get "/feedback", :to => redirect("/contact"), :format => false
  post "/feedback", :to => "contact/govuk/problem_reports#create", :format => false
  get "/feedback/contact", :to => redirect("/contact/govuk"), :format => false
  post "/feedback/contact", :to => "contact/govuk#create", :format => false
  get "/feedback/foi", :to => redirect("/contact/foi"), :format => false
  post "/feedback/foi", :to => "contact/foi#create", :format => false

  root :to => redirect("/contact")

  if Rails.env.development? or Rails.env.test?
    get "test_forms/report_a_problem"
  end
end
