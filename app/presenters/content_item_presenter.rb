class ContentItemPresenter
  attr_reader :content_item

  def initialize(content_item)
    @content_item = content_item
  end

  PASS_THROUGH_KEYS = %i[
    base_path content_id details description locale title
  ].freeze

  PASS_THROUGH_DETAILS_KEYS = [
    :promotion,
  ].freeze

  PASS_THROUGH_KEYS.each do |key|
    define_method key do
      content_item[key.to_s]
    end
  end

  PASS_THROUGH_DETAILS_KEYS.each do |key|
    define_method key do
      details[key.to_s] if details
    end
  end

  def slug
    base_path.split("/").last
  end

  def format
    @content_item["schema_name"]
  end

  def short_description
    nil
  end

  def web_url
    Plek.new.website_root + base_path
  end
end
