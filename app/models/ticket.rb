class Ticket
  include ActiveModel::Validations
  attr_accessor :val, :user_agent, :varnish_id

  # This is deliberately higher than the max character count
  # in the front-end (javascript and maxlength in the markup),
  # because certain browsers treat "\r\n" incorrectly as
  # 1 character long.
  FIELD_MAXIMUM_CHARACTER_COUNT = 1250

  validate :validate_val

  def initialize(attributes = {})
    attributes.each do |key, value|
      if respond_to? "#{key}="
        send("#{key}=", value)
      end
    end
    valid?
  end

  def spam?
    errors[:val] && errors[:val].any?
  end

  private
  def validate_val
    # val is used as a naive bot-preventor
    unless val.blank?
      @errors.add :val
    end
  end

  def valid_url?(candidate)
    url = URI.parse(candidate) rescue false
    url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS)
  end

  def url_if_valid(candidate)
    valid_url?(candidate) ? candidate : nil
  end
end
