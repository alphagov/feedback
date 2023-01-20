class ServiceFeedbackController < ContactController
  def new
    @publication = helpers.publication

    respond_to do |format|
      format.html do
        render :new
      end
      format.any do
        head(:not_acceptable)
      end
    end
  end
end
