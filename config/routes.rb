Feedback::Application.routes.draw do

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # See how all your routes lay out with "rake routes"

  get "/ask-a-question", :to => "ask_a_question#landing"
  post "/ask-a-question", :to => "ask_a_question#submit"
  get "/feedback", :to => "feedback#landing"
  post "/feedback", :to => "feedback#submit"

  root :to => redirect("/feedback", :status => 302)

  if Rails.env.development? or Rails.env.test?
    get "test_forms/report_a_problem"
  end
end
