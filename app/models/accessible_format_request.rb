class AccessibleFormatRequest
  include ActiveModel::Validations
  attr_accessor :document_title, :publication_path, :format_type, :custom_details, :contact_name, :alternative_format_email, :contact_email

  validates :document_title, presence: true
  validates :publication_path, presence: true
  validates :format_type, presence: true
  validates :alternative_format_email,
            presence: true,
            email: { message: "The email address must be valid" }
  validates :contact_email,
            presence: true,
            email: { message: "The email address must be valid" }

  def initialize(attributes = {})
    attributes.each do |key, value|
      send("#{key}=", value) if respond_to? "#{key}="
    end
  end
end
