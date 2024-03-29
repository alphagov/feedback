Rails.application.config.problem_report_spam_matchers = [
  # a cursory Google search suggests that the following pattern is generated by the WebCruiser
  # scanning tool
  ->(ticket) { ticket.what_wrong =~ /WCRTESTINP/ },
  # as above
  ->(ticket) { ticket.what_doing =~ /WCRTESTINP/ },

  # get rid of very low-quality feedback where "what_wrong" and "what_doing" are
  # either single words or missing completely
  ->(ticket) { ticket.what_wrong.exclude?(" ") && ticket.what_doing.exclude?(" ") },
  ->(ticket) { ticket.giraffe.present? },
  # mark duplicate values in "what_wrong" and "what_doing" fields as spam
  ->(ticket) { ticket.what_wrong == ticket.what_doing },
  # prevent a bot that might submit the form quickly
  ->(ticket) { ticket.javascript_enabled && ticket.timer.to_i <= 4 },
].freeze
