Feedback::Application.routes.draw do

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # See how all your routes lay out with "rake routes"

  get "/ask-a-question", :to => "ask_a_question#index"
  post "/ask-a-question", :to => "ask_a_question#submit"
  get "/general-feedback", :to => "general_feedback#index"
  post "/general-feedback", :to => "general_feedback#submit"
  get "/foi", :to => "foi#index"
  post "/foi", :to => "foi#submit"
  get "/i-cant-find", :to => "i_cant_find#index"
  post "/i-cant-find", :to => "i_cant_find#submit"
  get "/feedback", :to => "feedback#index"
  post "/feedback", :to => "report_a_problem#submit_without_validation"
  get "/report-a-problem", :to => "report_a_problem#index"
  post "/report-a-problem", :to => "report_a_problem#submit"

  root :to => redirect("/feedback", :status => 302)

  if Rails.env.development? or Rails.env.test?
    get "test_forms/report_a_problem"
  end
end
