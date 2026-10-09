class Contact::GovukApp::ChatFeedbackController < ApplicationController
  include ThrottlingManager

  rescue_from ActionController::ParameterMissing, with: :parameter_missing_error

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
    params.require(:chat_feedback).permit(
      :giraffe,
      :feedback,
      :reply,
      :name,
      :email,
    )
  end

  def parameter_missing_error
    render plain: "Required parameter is missing", status: :bad_request
  end
end
