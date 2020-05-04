require "uri"

class Ticket
  include ActiveModel::Validations
  attr_accessor :giraffe, :user_agent
  attr_writer :url

  # This is deliberately higher than the max character count
  # in the front-end (javascript and maxlength in the markup),
  # because certain browsers treat "\r\n" incorrectly as
  # 1 character long.
  FIELD_MAXIMUM_CHARACTER_COUNT = 1250

  validate :validate_giraffe
  validates :url, length: { maximum: 2048 }
  validates :user_agent, length: { maximum: 2048 }

  def initialize(attributes = {})
    attributes.each do |key, value|
      send("#{key}=", value) if respond_to? "#{key}="
    end
    valid?
  end

  def spam?
    errors[:giraffe] && errors[:giraffe].any?
  end

  def url
    UrlNormaliser.url_if_valid(@url)
  end

  def path
    url ? URI(url).path : nil
  end

  def referrer=(new_referrer)
    @referrer = (new_referrer == "unknown" ? nil : new_referrer)
  end

  def referrer
    UrlNormaliser.url_if_valid(@referrer)
  end

private

  def validate_giraffe
    # giraffe is used as a naive bot-preventor
    @errors.add :giraffe if giraffe.present?
  end
end
