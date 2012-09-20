Feedback::Application.routes.draw do

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # See how all your routes lay out with "rake routes"

  get "/feedback/ask-a-question", :to => "ask_a_question#index"
  post "/feedback/ask-a-question", :to => "ask_a_question#submit"
  get "/feedback/general-feedback", :to => "general_feedback#index"
  post "/feedback/general-feedback", :to => "general_feedback#submit"
  get "/feedback/foi", :to => "foi#index"
  post "/feedback/foi", :to => "foi#submit"
  get "/feedback/i-cant-find", :to => "i_cant_find#index"
  post "/feedback/i-cant-find", :to => "i_cant_find#submit"
  get "/feedback", :to => "feedback#index"
  post "/feedback", :to => "report_a_problem#submit_without_validation"
  get "/feedback/report-a-problem", :to => "report_a_problem#index"
  post "/feedback/report-a-problem", :to => "report_a_problem#submit"

  root :to => redirect("/feedback", :status => 302)

  if Rails.env.development? or Rails.env.test?
    get "test_forms/report_a_problem"
  end
end
