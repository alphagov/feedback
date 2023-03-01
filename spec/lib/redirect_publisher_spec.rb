require "rails_helper"
require "./app/lib/redirect_publisher"
require "govuk_schemas/rspec_matchers"

RSpec.describe RedirectPublisher do
  RSpec.configuration.include GovukSchemas::RSpecMatchers

  let(:logger) { double(:logger) }

  it "publishes redirects" do
    content_id = SecureRandom.uuid
    current_base_path = "/feedback"
    destination_path = "/contact"

    expected_redirect = {
      "base_path" => current_base_path,
      "schema_name" => "redirect",
      "document_type" => "redirect",
      "publishing_app" => "feedback",
      "update_type" => "major",
      "redirects" => [
        {
          "path" => current_base_path,
          "type" => "exact",
          "destination" => destination_path,
        },
      ],
    }

    api = double(:publishing_api)

    expect(api).to receive(:put_content).with(content_id, expected_redirect)
    expect(api).to receive(:publish).once.with(content_id)

    expect(logger).to receive(:info)
      .with("Registering redirect #{content_id}: '#{current_base_path}' -> '#{destination_path}'")

    redirect_publisher = RedirectPublisher.new(
      logger:,
      publishing_app: "feedback",
      type: "exact",
      publishing_api: api,
    )

    redirect_publisher.call(
      content_id:,
      current_base_path:,
      destination_path:,
    )
  end

  it "publishes redirects that are valid" do
    content_id = SecureRandom.uuid
    current_base_path = "/feedback"
    destination_path = "/contact"

    api = double(:publishing_api)
    expect(api).to receive(:put_content).with(an_instance_of(String), be_valid_against_publisher_schema("redirect"))
    expect(api).to receive(:publish).once.with(content_id)

    expect(logger).to receive(:info)
      .with("Registering redirect #{content_id}: '#{current_base_path}' -> '#{destination_path}'")

    redirect_publisher = RedirectPublisher.new(
      logger:,
      publishing_app: "feedback",
      type: "exact",
      publishing_api: api,
    )

    redirect_publisher.call(
      content_id:,
      current_base_path:,
      destination_path:,
    )
  end
end
