class FeedbackController < ApplicationController
  def landing
  end

  def submit
    render :action => 'thankyou'
  end
end
