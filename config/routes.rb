Feedback::Application.routes.draw do

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # See how all your routes lay out with "rake routes"

  get "/feedback", :to => redirect("/feedback/contact"), :format => false
  post "/feedback", :to => "contact/govuk/problem_reports#create", :format => false
  get "/feedback/contact", :to => "contact/govuk#new", :format => false
  post "/feedback/contact", :to => "contact/govuk#create", :format => false
  get "/feedback/foi", :to => "contact/foi#new", :format => false
  post "/feedback/foi", :to => "contact/foi#create", :format => false

  root :to => redirect("/feedback", :status => 302)

  if Rails.env.development? or Rails.env.test?
    get "test_forms/report_a_problem"
  end
end
