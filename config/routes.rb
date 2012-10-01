Feedback::Application.routes.draw do

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # See how all your routes lay out with "rake routes"

  get "/feedback", :to => "feedback#contact"
  post "/feedback/contact", :to => "feedback#contact_submit"
  post "/feedback", :to => "feedback#report_a_problem_submit_without_validation"
  get "/feedback/foi", :to => "feedback#foi"
  post "/feedback/foi", :to => "feedback#foi_submit"

  root :to => redirect("/feedback", :status => 302)

  if Rails.env.development? or Rails.env.test?
    get "test_forms/report_a_problem"
  end
end
