class Contact::GovukApp::SuggestionsController < ApplicationController
  include ThrottlingManager

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
    params[:suggestion].slice(
      :giraffe,
      :details,
      :reply,
      :name,
      :email,
    ).permit!
  end
end
