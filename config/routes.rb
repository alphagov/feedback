Feedback::Application.routes.draw do

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # See how all your routes lay out with "rake routes"

  get "/feedback", :to => "feedback#landing"
  post "/feedback", :to => "feedback#report_a_problem_submit_without_validation"
  get "/feedback/ask-a-question", :to => "feedback#ask_a_question"
  post "/feedback/ask-a-question", :to => "feedback#ask_a_question_submit"
  get "/feedback/general-feedback", :to => "feedback#general_feedback"
  post "/feedback/general-feedback", :to => "feedback#general_feedback_submit"
  get "/feedback/foi", :to => "feedback#foi"
  post "/feedback/foi", :to => "feedback#foi_submit"
  get "/feedback/i-cant-find", :to => "feedback#i_cant_find"
  post "/feedback/i-cant-find", :to => "feedback#i_cant_find_submit"
  get "/feedback/report-a-problem", :to => "feedback#report_a_problem"
  post "/feedback/report-a-problem", :to => "feedback#report_a_problem_submit"

  root :to => redirect("/feedback", :status => 302)

  if Rails.env.development? or Rails.env.test?
    get "test_forms/report_a_problem"
  end
end
