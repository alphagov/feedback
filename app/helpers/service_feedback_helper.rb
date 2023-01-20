require "gds_api/publishing_api"

module ServiceFeedbackHelper
  def content_item_hash
    @content_item_hash ||= completed_transaction_content_item.to_h
  end

  def publication
    @publication ||= ContentItemPresenter.new(content_item_hash)
  end

private

  def completed_transaction_content_item
    @completed_transaction_content_item ||= request.env[:content_item] || request_content_item
  end

  def request_content_item(base_path = "/#{params[:slug]}")
    GdsApi.content_store.content_item(base_path)
  end
end
