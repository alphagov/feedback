Feedback::Application.routes.draw do

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # See how all your routes lay out with "rake routes"

  get "/feedback", :to => "feedback#landing"

  root :to => redirect("/feedback", :status => 302)
end
