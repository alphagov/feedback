class Contact::GovukApp::SuggestionsController < ApplicationController
  include ThrottlingManager

  rescue_from ActionController::ParameterMissing, with: :parameter_missing_error

  def new; end

  def create
    ticket = AppSuggestionTicket.new(suggestion_params)

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

  def suggestion_params
    params.require(:suggestion).permit(
      :giraffe,
      :details,
      :reply,
      :name,
      :email,
    )
  end

  def parameter_missing_error
    render plain: "Required parameter is missing", status: :bad_request
  end
end
