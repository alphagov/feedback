class FeedbackController < ApplicationController
  before_filter :set_cache_control, :only => [:landing]

  def landing
  end

  private

  def set_cache_control
    expires_in 10.minutes, :public => true unless Rails.env.development?
  end
end
