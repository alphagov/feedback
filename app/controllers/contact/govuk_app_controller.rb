class Contact::GovukAppController < ApplicationController
  def new; end

  def create
    if type == "problem"
      redirect_to contact_govuk_app_report_problem_path
    else
      redirect_to contact_govuk_app_make_suggestion_path
    end
  end

  def confirmation; end

private

  def type
    params[:contact][:type]
  end
end
