Feedback::Application.routes.draw do

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # See how all your routes lay out with "rake routes"

  get "/feedback", :to => "feedback#feedback", :format => false
  post "/feedback", :to => "feedback#report_a_problem_submit", :format => false
  get "/feedback/contact", :to => "feedback#contact", :format => false
  post "/feedback/contact", :to => "feedback#contact_submit", :format => false
  get "/feedback/foi", :to => "feedback#foi", :format => false
  post "/feedback/foi", :to => "feedback#foi_submit", :format => false

  # Feedback routes are moving to the /contact routes below.
  # The above routes can be safely removed once redirects are in place
  # for the old /feedback URLs.
  get "/contact", :to => "feedback#feedback", :format => false
  post "/contact", :to => "feedback#report_a_problem_submit", :format => false
  get "/contact/form", :to => "feedback#contact", :format => false
  post "/contact/form", :to => "feedback#contact_submit", :format => false
  get "/contact/foi", :to => "feedback#foi", :format => false
  post "/contact/foi", :to => "feedback#foi_submit", :format => false

  root :to => redirect("/feedback", :status => 302)

  if Rails.env.development? or Rails.env.test?
    get "test_forms/report_a_problem"
  end
end
