require "rails_helper"

RSpec.describe AccessibleFormatRequest, type: :model do
  subject(:accessible_format_request) { described_class.new(request_options) }
  let(:request_options) do
    {
      document_title: "An example title",
      publication_path: "/example/path",
      format_type: "Braille",
      contact_name: "J Doe",
      contact_email: "doe@example.com",
      alternative_format_email: "department@example.com",
    }
  end

  describe "validations" do
    it { is_expected.not_to allow_value(nil).for(:document_title) }
    it { is_expected.not_to allow_value(nil).for(:publication_path) }
    it { is_expected.not_to allow_value(nil).for(:format_type) }
    it { is_expected.not_to allow_value(nil).for(:contact_email) }
    it { is_expected.not_to allow_value("this15n0+A|\\|email").for(:contact_email) }
    it { is_expected.not_to allow_value("abc @d.com").for(:contact_email) }
    it { is_expected.not_to allow_value("abc@d.com.").for(:contact_email) }
    it { is_expected.not_to allow_value(nil).for(:alternative_format_email) }
    it { is_expected.not_to allow_value("this15n0+A|\\|email").for(:alternative_format_email) }
    it { is_expected.not_to allow_value("abc @d.com").for(:alternative_format_email) }
    it { is_expected.not_to allow_value("abc@d.com.").for(:alternative_format_email) }
  end
end
