require "rails_helper"

RSpec.describe AccessibleFormatRequest, type: :model do
  subject(:accessible_format_request) { described_class.new(request_options) }
  let(:document_title) { "An example title" }
  let(:publication_path) { "/example/path" }
  let(:format_type) { "large-print" }
  let(:contact_name) { "J Doe" }
  let(:contact_email) { "test@example.com" }
  let(:alternative_format_email) { "department@example.com" }
  let(:request_options) do
    {
      document_title:,
      publication_path:,
      format_type:,
      contact_name:,
      contact_email:,
      alternative_format_email:,
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
    it { is_expected.to allow_value("abc@d.com").for(:contact_email) }
    it { is_expected.not_to allow_value(nil).for(:alternative_format_email) }
    it { is_expected.not_to allow_value("this15n0+A|\\|email").for(:alternative_format_email) }
    it { is_expected.not_to allow_value("abc @d.com").for(:alternative_format_email) }
    it { is_expected.not_to allow_value("abc@d.com.").for(:alternative_format_email) }
    it { is_expected.to allow_value("abc@d.com").for(:alternative_format_email) }
  end

  describe "#to_notify_params" do
    subject { accessible_format_request.to_notify_params }

    it "includes the default template_id" do
      expect(subject[:template_id]).to eq "fake-test-accessible-format-request-template-id"
    end

    it "includes the alternative format request email as the recipient" do
      expect(subject[:email_address]).to eq alternative_format_email
    end

    it "includes the users contact name" do
      expect(subject[:personalisation][:contact_name]).to eq contact_name
    end

    context "when a contact name is not provided" do
      let(:contact_name) { nil }
      it "includes the default text when users name is not provided" do
        expect(subject[:personalisation][:contact_name]).to eq "Not provided"
      end
    end

    it "includes the users email address" do
      expect(subject[:personalisation][:contact_email]).to eq contact_email
    end

    it "includes the document title" do
      expect(subject[:personalisation][:document_title]).to eq document_title
    end

    it "includes the publication path" do
      expect(subject[:personalisation][:publication_path]).to eq publication_path
    end

    it "includes a reference to uniquely connect the signup to the notification" do
      expect(subject[:reference]).to eq "accessible-format-request-#{accessible_format_request.object_id}"
    end

    it "includes the default reply_to_id" do
      expect(subject[:email_reply_to_id]).to eq "fake-test-accessible-format-request-reply-to-id"
    end

    context "when a standard format type has been selected" do
      it "includes the format type capitalized with underscores removed" do
        expect(subject[:personalisation][:format_type]).to eq "Large print"
      end

      it "includes the default text for custom details" do
        expect(subject[:personalisation][:custom_details]).to eq "Not provided"
      end
    end

    context "when a custom format has been selected" do
      let(:format_type) { "custom_details" }
      let(:custom_details) { "I would like it in a different format please" }
      let(:request_options) do
        {
          format_type:,
          custom_details:,
          contact_name:,
          contact_email:,
        }
      end

      it "includes the format type capitalized with underscores removed" do
        expect(subject[:personalisation][:format_type]).to eq "Custom details"
      end

      it "includes the custom format text" do
        expect(subject[:personalisation][:custom_details]).to eq custom_details
      end
    end
  end

  describe "#save" do
    it "sends an email to the email address using GOV.UK notify" do
      expect(Rails.application.config.notify_service).to receive(:send_email).with(accessible_format_request)
      subject.save
    end

    it "should raise an exception if the GOV.UK notify call doesn't work" do
      allow(Rails.application.config.notify_service).to receive(:send_email).and_raise(NotifyService::Error.new("uh-oh!"))
      expect { subject.save }.to raise_error(NotifyService::Error, "uh-oh!")
    end
  end
end
