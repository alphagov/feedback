require 'ticket_client'

class FeedbackController < ApplicationController
  TICKET_PARAMS = %w(url what_doing what_happened what_expected)

  def landing
  end

  def submit
    TicketClient.report_a_problem(params.select {|k,v| TICKET_PARAMS.include?(k) }.symbolize_keys)
    render :action => 'thankyou'
  end
end
