class FeedbackController < ApplicationController
  @@TITLE = "Feedback"
  @@HEADER = @@TITLE + @@MASTER_HEADER

  def index
    @header = @@HEADER
  end
end
