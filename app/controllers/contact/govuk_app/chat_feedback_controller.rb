class Contact::GovukApp::ChatFeedbackController < ApplicationController
  include ThrottlingManager

  def new; end

  def create
    ticket = AppChatFeedbackTicket.new(chat_feedback_params)

    if ticket.valid?
      ticket.save
      redirect_to contact_govuk_app_confirmation_path
    else
      decrement_throttle_counts

      @errors = ticket.errors.messages
      @ticket = ticket
      render "new"
    end
  end

private

  def chat_feedback_params
    params[:chat_feedback].slice(
      :giraffe,
      :feedback,
      :reply,
      :name,
      :email,
    ).permit!
  end
end
