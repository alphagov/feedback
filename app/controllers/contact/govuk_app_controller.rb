class Contact::GovukAppController < ApplicationController
  def new; end

  def create
    if errors
      return render "new"
    end

    if type == "problem"
      redirect_to contact_govuk_app_report_problem_path(params: phone_details_params)
    else
      redirect_to contact_govuk_app_make_suggestion_path
    end
  end

  def confirmation; end

  helper_method :phone_details_params
  def phone_details_params
    params.slice(:phone, :app_version, :what_happened).permit!
  end

private

  def type
    params[:contact][:type]
  end

  def blank_or_invalid_type?
    return true unless params[:contact]

    %w[problem suggestion].exclude?(type)
  end

  def errors
    if blank_or_invalid_type?
      @errors = {
        contact_type: [t("controllers.contact.govuk_app.new.contact_type_error_message")],
      }
    end
  end
end
