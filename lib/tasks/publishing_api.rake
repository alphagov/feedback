require './lib/redirect_publisher'

require 'logger'
require 'gds_api/publishing_api'
require 'gds_api/publishing_api/special_route_publisher'

namespace :publishing_api do
  def publishing_api
    GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
    )
  end

  desc 'Publish special routes via publishing api'
  task :publish_special_routes do
    logger = Logger.new(STDOUT)
    special_route_publisher = GdsApi::PublishingApi::SpecialRoutePublisher.new(
      logger: logger,
      publishing_api: publishing_api
    )

    special_route_publisher.publish(
      content_id: "58b05bc2-fde5-4a0b-af73-8edc532674f8",
      title: "Government contacts",
      base_path: "/contact",
      type: "prefix",
      publishing_app: 'feedback',
      rendering_app: 'feedback'
    )

    redirect_publisher = RedirectPublisher.new(
      logger: logger,
      publishing_app: 'feedback',
      publishing_api: publishing_api
    )

    redirect_publisher.call(
      content_id: 'be88ff3e-deb3-4a6e-b6ac-d6d12b50ac3d',
      current_base_path: '/feedback',
      destination_path: '/contact'
    )

    redirect_publisher.call(
      content_id: '16a89a3b-bd41-4bce-adaf-7505b844632f',
      current_base_path: '/feedback/contact',
      destination_path: '/contact/govuk'
    )

    redirect_publisher.call(
      content_id: 'a6d9bafd-f69b-4d2f-a002-c7547473e152',
      current_base_path: '/feedback/foi',
      destination_path: '/contact/foi'
)

    redirect_publisher.call(
      content_id: 'd9f4ef65-4efb-4865-a562-c41d9794b796',
      current_base_path: '/contact/dvla',
      destination_path: '/contact-the-dvla'
)

    redirect_publisher.call(
      content_id: '80ea2f60-c900-4c73-a129-d5418fc7d12d',
      current_base_path: '/contact/passport-advice-line',
      destination_path: '/passport-advice-line'
    )

    redirect_publisher.call(
      content_id: '4dee002d-6d26-47ff-b192-7e0392805f9f',
      current_base_path: '/contact/student-finance-england',
      destination_path: '/contact-student-finance-england'
    )

    redirect_publisher.call(
      content_id: 'b7f6e48e-9d2c-4789-a64f-455921dca0d0',
      current_base_path: '/contact/jobcentre-plus',
      destination_path: '/contact-jobcentre-plus'
    )
  end
end
