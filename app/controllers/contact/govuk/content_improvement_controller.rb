class Contact::Govuk::ContentImprovementController < ContactController
  def create
    begin
      response = Rails.application.config.support_api.create_content_improvement_feedback(feedback_params)

      render json: { status: "success" }, status: response.code
    rescue GdsApi::HTTPUnprocessableEntity => e
      render json: e.error_details, status: e.code
    end
  end

  def feedback_params
    params.slice(:description)
  end
end
