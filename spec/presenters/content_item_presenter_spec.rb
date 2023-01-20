require "rails_helper"
require "gds_api/test_helpers/support_api"
require "gds_api/test_helpers/content_store"

RSpec.describe ContentItemPresenter do
  include GdsApi::TestHelpers::ContentStore
  let(:slug) { "done/some-transaction" }
  let(:payload) do
    {
      base_path: "/done/some-transaction",
      schema_name: "completed_transaction",
      document_type: "completed_transaction",
      external_related_links: [],
      title: "Some Transaction",
      description: "Some description",
      content_id: "ae85eb0e-fba2-47c4-b1f2-fbf6aa36352d",
      locale: "en",
      details: {
        "promotion": {
          "url": "https://energysavingtrust.org.uk/advice/electric-vehicles/",
          "category": "electric_vehicle",
        },
      },
    }
  end
  let(:content_item_presenter) { ContentItemPresenter.new(payload.deep_stringify_keys!) }

  before do
    setup_content_item_presenter
  end

  it "initialises a with a content item hash" do
    expect(content_item_presenter.content_item).to eql({
      "base_path" => "/done/some-transaction",
      "schema_name" => "completed_transaction",
      "document_type" => "completed_transaction",
      "external_related_links" => [],
      "title" => "Some Transaction",
      "description" => "Some description",
      "content_id" => "ae85eb0e-fba2-47c4-b1f2-fbf6aa36352d",
      "locale" => "en",
      "details" => {
        "promotion" => {
          "category" => "electric_vehicle",
          "url" => "https://energysavingtrust.org.uk/advice/electric-vehicles/",
        },
      },
    })
  end

  it "presents the base_path" do
    expect(content_item_presenter.base_path).to eql("/done/some-transaction")
  end

  it "presents the content_id" do
    expect(content_item_presenter.content_id).to eql("ae85eb0e-fba2-47c4-b1f2-fbf6aa36352d")
  end

  it "presents the details" do
    expect(content_item_presenter.details).to eql({ "promotion" => { "category" => "electric_vehicle", "url" => "https://energysavingtrust.org.uk/advice/electric-vehicles/" } })
  end

  it "presents the description" do
    expect(content_item_presenter.description).to eql("Some description")
  end

  it "presents the locale" do
    expect(content_item_presenter.locale).to eql("en")
  end

  it "presents the title" do
    expect(content_item_presenter.title).to eql("Some Transaction")
  end

  it "presents items in the details hash" do
    expect(content_item_presenter.promotion).to eql(
      {
        "category" => "electric_vehicle",
        "url" => "https://energysavingtrust.org.uk/advice/electric-vehicles/",
      },
    )
  end

  it "presents the slug" do
    expect(content_item_presenter.slug).to eql("done/some-transaction")
  end

  it "presents the format" do
    expect(content_item_presenter.format).to eql("completed_transaction")
  end

  it "presents the short_description" do
    expect(content_item_presenter.short_description).to eql(nil)
  end

  it "presents the web_url" do
    expect(content_item_presenter.web_url).to eql("#{Plek.new.website_root}/done/some-transaction")
  end

  def setup_content_item_presenter
    stub_content_store_has_item("/#{slug}", payload)
    content_item_presenter
  end
end
