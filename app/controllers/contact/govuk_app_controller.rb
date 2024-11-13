class Contact::GovukAppController < ApplicationController
  def new; end

  def create
    if errors
      return render "new", locals: { form_errors: errors }
    end

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

  def blank_or_invalid_type?
    return true unless params[:contact]

    %w[problem suggestion].exclude?(type)
  end

  def errors
    if blank_or_invalid_type?
      {
        contact_type: [t("controllers.contact.govuk_app.new.contact_type_error_message")],
      }
    end
  end
end
