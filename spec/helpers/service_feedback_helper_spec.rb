require "rails_helper"
require "gds_api/test_helpers/content_store"

RSpec.describe ServiceFeedbackHelper, type: :helper do
  include ServiceFeedbackHelper
  include GdsApi::TestHelpers::ContentStore

  let(:payload) do
    {
      base_path: slug,
      schema_name: "completed_transaction",
      document_type: "completed_transaction",
      external_related_links: [],
      title: "Some Transaction",
    }
  end

  let(:slug) { "done/some-transaction" }

  before do
    stub_content_store_has_item("/#{slug}", payload)
    params[:slug] = slug
  end

  describe "#content_item_hash" do
    it "returns a hash of content item data" do
      expect(helper.content_item_hash).to eql({
        "base_path" => slug,
        "document_type" => "completed_transaction",
        "external_related_links" => [],
        "schema_name" => "completed_transaction",
        "title" => "Some Transaction",
      })
    end
  end

  describe "#publication" do
    it "returns an instance of ContentItemPresenter" do
      expect(helper.publication).to be_a(ContentItemPresenter)
    end
  end

  describe "set_locale" do
    it "sets the default locale to Welsh when locale is cy" do
      payload.merge!({ locale: "cy" })
      stub_content_store_has_item("/#{slug}", payload)

      expect(helper.set_locale).to eql("cy")
    end
  end
end
