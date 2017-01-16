class RedirectPublisher
  attr_reader :logger, :publishing_app, :type, :publishing_api

  def initialize(logger:, publishing_app:, type: "exact", publishing_api:)
    @logger = logger
    @publishing_app = publishing_app
    @type = type
    @publishing_api = publishing_api
  end

  def call(content_id:, current_base_path:, destination_path:)
    logger.info("Registering redirect #{content_id}: '#{current_base_path}' -> '#{destination_path}'")

    redirect = {
      "content_id" => content_id,
      "base_path" => current_base_path,
      "schema_name" => "redirect",
      "document_type" => "redirect",
      "publishing_app" => publishing_app,
      "update_type" => "major",
      "redirects" => [
        {
          "path" => current_base_path,
          "type" => type,
          "destination" => destination_path
        }
      ]
    }

    publishing_api.put_content(content_id, redirect)
    publishing_api.publish(content_id, "major")
  end
end
