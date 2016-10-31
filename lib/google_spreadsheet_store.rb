require 'google_credentials'
require 'google/apis/sheets_v4'

class GoogleSpreadsheetStore
  # Rename SheetsV4 to Sheets - seems to be standard practice to make upgrades easier
  Sheets = Google::Apis::SheetsV4

  class Error < StandardError
    attr_reader :cause
    def initialize(message, cause: nil)
      super(message)
      @cause = cause
    end
  end

  SCOPES = ['https://www.googleapis.com/auth/spreadsheets'].freeze

  def initialize(spreadsheet_key)
    @spreadsheet_key = spreadsheet_key
  end

  def store(row_data)
    # Assumption is we're storing 1 row, values expects to be many rows
    data = Sheets::ValueRange.from_json({ values: [row_data] }.to_json)
    sheet_service.append_spreadsheet_value(
      spreadsheet_key,
      'Sheet1',
      data,
      value_input_option: 'RAW',
      insert_data_option: 'INSERT_ROWS'
    )
  rescue Google::Apis::Error => e
    raise Error.new("Error while storing data in google (#{e.message})", cause: e)
  end

  def self.sheet_service
    @sheet_service ||= connect_to_sheet_service
  end

  def self.connect_to_sheet_service
    sheets = Sheets::SheetsService.new
    sheets.authorization = GoogleCredentials.authorization(SCOPES)
    sheets
  end
  private_class_method :connect_to_sheet_service

private

  attr_reader :spreadsheet_key

  def sheet_service
    self.class.sheet_service
  end
end
