class Contact::Govuk::PageImprovementsController < ApplicationController
  def create
    response = Rails.application.config.support_api.create_page_improvement(page_improvements_params)

    render json: { status: "success" }, status: response.code
  rescue GdsApi::HTTPUnprocessableEntity => e
    render json: e.error_details, status: e.code
  end

  def page_improvements_params
    params.slice(:description, :email, :name, :url, :user_agent)
  end
end
