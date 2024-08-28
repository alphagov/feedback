class Contact::Govuk::ProblemReportsController < ContactController
  DONE_OK_TEXT = "<h1 class='govuk-heading-l'>Thank you for your help.</h1> " \
    "<p class='govuk-body'>If you have more extensive feedback, " \
    "please visit the <a class='govuk-link' href='/contact'>contact page</a>.</p>".freeze
  DONE_INVALID_TEXT = "<h1 class='govuk-heading-l'>Sorry, we're unable to send your message as you haven't given us any information.</h1> " \
    "<p class='govuk-body'>Please tell us what you were doing or what went wrong.</p>".freeze

  def create
    attributes = params.merge(technical_attributes)

    # Where the 'url' parameter isn't explicitly provided, obtain it
    # from the HTTP referer. This is an edge case in the app as there
    # should only be a finite number of places where this occurs.
    # Specifially, the 40X pages on GOV.UK.
    attributes = attributes.merge(url: request.referer) unless params.key? :url

    ticket = ReportAProblemTicket.new(attributes)

    if ticket.valid?
      ticket.save

      hide_report_a_problem_form_in_response
      @message = DONE_OK_TEXT.html_safe
      status = 201
      status_text = "success"
    else
      @message = DONE_INVALID_TEXT.html_safe
      status = 422
      status_text = "error"
    end

    respond_to do |format|
      format.html do
        @return_path = extract_return_path(params[:url])
        # not returning the strictly correct status code here because
        # nginx is currently configured to intercept 4XX errors
        # and replace what the app sends back with a standard error page
        render "contact/govuk/problem_reports/thankyou"
      end
      format.js do
        response = { message: @message, status: status_text }
        response[:errors] = ticket.errors.full_messages unless ticket.valid?

        render json: response, status:
      end
    end
  end

private

  def extract_return_path(url)
    return nil if url.blank?

    uri = URI.parse(url)
    return_path = uri.path
    return_path << "?#{uri.query}" if uri.query.present?
    return_path
  rescue URI::InvalidURIError
    nil
  end
end
