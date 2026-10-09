class Contact::GovukApp::ProblemReportsController < ApplicationController
  include ThrottlingManager

  rescue_from ActionController::ParameterMissing, with: :parameter_missing_error

  def new
    @phone = params[:phone]
    @app_version = params[:app_version]
    @what_happened = params[:what_happened]
  end

  def create
    ticket = AppProblemReportTicket.new(problem_report_params)

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

  def problem_report_params
    params.require(:problem_report).permit(
      :giraffe,
      :phone,
      :app_version,
      :trying_to_do,
      :what_happened,
      :reply,
      :name,
      :email,
    )
  end

  def parameter_missing_error
    render plain: "Required parameter is missing", status: :bad_request
  end
end
