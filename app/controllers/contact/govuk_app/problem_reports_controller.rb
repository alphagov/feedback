class Contact::GovukApp::ProblemReportsController < ApplicationController
  def new
    @phone = params[:phone]
    @app_version = params[:app_version]
  end

  def create
    ticket = AppProblemReportTicket.new(problem_report_params)

    if ticket.valid?
      ticket.save
      redirect_to contact_govuk_app_confirmation_path
    else
      @errors = ticket.errors.messages
      @ticket = ticket
      render "new"
    end
  end

private

  def problem_report_params
    params[:problem_report].slice(
      :giraffe,
      :phone,
      :app_version,
      :trying_to_do,
      :what_happened,
      :reply,
      :name,
      :email,
    ).permit!
  end
end
