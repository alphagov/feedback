require 'uri'

class Ticket
  include ActiveModel::Validations
  attr_accessor :val, :user_agent, :url

  # This is deliberately higher than the max character count
  # in the front-end (javascript and maxlength in the markup),
  # because certain browsers treat "\r\n" incorrectly as
  # 1 character long.
  FIELD_MAXIMUM_CHARACTER_COUNT = 1250

  validate :validate_val
  validates_length_of :url, maximum: 2048
  validates_length_of :user_agent, maximum: 2048

  def initialize(attributes = {})
    attributes.each do |key, value|
      send("#{key}=", value) if respond_to? "#{key}="
    end
    valid?
  end

  def spam?
    errors[:val] && errors[:val].any?
  end

  def url
    url_if_valid(@url)
  end

  def path
    url ? URI(url).path : nil
  end

  def referrer=(new_referrer)
    @referrer = (new_referrer == 'unknown' ? nil : new_referrer)
  end

  def referrer
    url_if_valid(@referrer)
  end

  private
  def validate_val
    # val is used as a naive bot-preventor
    @errors.add :val unless val.blank?
  end

  def valid_url?(candidate)
    url = URI.parse(candidate) rescue false
    url.is_a?(URI::Generic) && (url.is_a?(URI::HTTP) || url.is_a?(URI::HTTPS) || url.relative?)
  end

  def url_if_valid(candidate)
    case
    when !valid_url?(candidate) then nil
    when URI.parse(candidate).relative? then Plek.new.website_root + candidate
    else candidate
    end
  end
end
