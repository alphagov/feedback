require 'logger'
require 'gds_api/publishing_api'
require 'gds_api/publishing_api/special_route_publisher'

class RedirectPublisher
  attr_reader :logger, :publishing_app, :type

  def initialize(logger:, publishing_app:, type: "exact")
    @logger = logger
    @publishing_app = publishing_app
    @type = type
  end

  def call(content_id, base_path, destination_path)
    logger.info("Registering redirect #{content_id}: '#{base_path}' -> '#{destination_path}'")

    redirect = {
      "content_id" => content_id,
      "format" => "redirect",
      "publishing_app" => publishing_app,
      "update_type" => "major",
      "redirects" => [
        {
          "path" => base_path,
          "type" => type,
          "destination" => destination_path
        }
      ]
    }

    publishing_api.put_content_item(base_path, redirect)
  end

private
  def publishing_api
    @publishing_api ||= GdsApi::PublishingApi.new(Plek.find("publishing-api"))
  end
end

namespace :publishing_api do
  desc 'Publish special routes via publishing api'
  task :publish_special_routes do
    logger = Logger.new(STDOUT)
    special_route_publisher = GdsApi::PublishingApi::SpecialRoutePublisher.new(logger: logger)
    special_route_publisher.publish(
      content_id: "58b05bc2-fde5-4a0b-af73-8edc532674f8",
      title: "Government contacts",
      base_path: "/contact",
      type: "prefix",
      publishing_app: 'feedback',
      rendering_app: 'feedback'
    )

    redirect_publisher = RedirectPublisher.new(logger: logger, publishing_app: 'feedback')
    redirect_publisher.call('be88ff3e-deb3-4a6e-b6ac-d6d12b50ac3d', '/feedback', '/contact')
    redirect_publisher.call('16a89a3b-bd41-4bce-adaf-7505b844632f', '/feedback/contact', '/contact/govuk')
    redirect_publisher.call('a6d9bafd-f69b-4d2f-a002-c7547473e152', '/feedback/foi', '/contact/foi')
    redirect_publisher.call('d9f4ef65-4efb-4865-a562-c41d9794b796', '/contact/dvla', '/contact-the-dvla')
    redirect_publisher.call('80ea2f60-c900-4c73-a129-d5418fc7d12d', '/contact/passport-advice-line', '/passport-advice-line')
    redirect_publisher.call('4dee002d-6d26-47ff-b192-7e0392805f9f', '/contact/student-finance-england', '/contact-student-finance-england')
    redirect_publisher.call('b7f6e48e-9d2c-4789-a64f-455921dca0d0', '/contact/jobcentre-plus', '/contact-jobcentre-plus')
  end
end

desc "Temporary alias of publishing_api:publish_special_routes for backward compatibility"
task "router:register" => "publishing_api:publish_special_routes"
