require "rails_helper"

RSpec.describe FormatRoutingConstraint do
  include GovukConditionalContentItemLoaderTestHelpers

  context "#matches?" do
    subject { described_class.new(@format) }
    context "when the content loader returns a document" do
      before do
        @format = "completed_transaction"
        stub_conditional_loader_returns_content_item_for_path(base_path, schema_name: @format)
        @request = request
      end

      it "return true if format matches" do
        expect(subject.matches?(@request)).to eq true
      end

      it "return false if format does not match" do
        @format = "another_format"
        expect(subject.matches?(@request)).to eq false
      end

      it "sets the content item on the request object" do
        subject.matches?(@request)

        expect(@request.env[:content_item]).to be_present
      end
    end

    context "when the API call throws an error" do
      before do
        stub_conditional_loader_does_not_return_content_item_for_path(base_path)
        @request = request
      end

      it "should return false" do
        @format = "any_format"
        expect(subject.matches?(@request)).to eq false
      end

      it "should set an error on the request object" do
        @format = "any_format"
        subject.matches?(@request)
        expect(@request.env[:content_item_error].present?).to be_present
      end
    end
  end

  def base_path
    "/done/some-transaction"
  end

  def request
    double({ params: { base_path: base_path }, path: base_path, env: {} })
  end
end
