require "rails_helper"
require "google_spreadsheet_store"

RSpec.describe GoogleSpreadsheetStore do
  before do
    stub_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/*})
    # Set auth to nil, and this won't try to incur extra requests
    allow(GoogleCredentials).to receive(:authorization).and_return nil
  end

  context "#store" do
    subject { described_class.new("my-spreadsheet-id") }

    it "writes the supplied data to a google spreadsheet as a single row" do
      subject.store(["some data", 1, 2, false, nil, "yes?", "6"])

      url = "https://sheets.googleapis.com/v4/spreadsheets/my-spreadsheet-id/values/Sheet1:append?valueInputOption=RAW&insertDataOption=INSERT_ROWS"
      store_request = a_request(:post, url).with(body: '{"values":[["some data",1,2,false,null,"yes?","6"]]}')
      expect(store_request).to have_been_requested
    end

    it "wraps any errors from the google API" do
      stub_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/my-spreadsheet-id/*}).to_return(status: 403, body: "forbidden")
      expect {
        subject.store(["some data", 1, 2, false, nil, "yes?", "6"])
      }.to(raise_error do |error|
        expect(error).to be_a described_class::Error
        expect(error.message).to match(/Error while storing data in google/)
        expect(error.cause).to be_a Google::Apis::Error
        expect(error.cause.body).to eq "forbidden"
      end)
    end
  end
end
