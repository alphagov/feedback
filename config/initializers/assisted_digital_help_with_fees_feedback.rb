require 'google_spreadsheet_store'

key = ENV['ASSISTED_DIGITAL_HELP_WITH_FEES_GOOGLE_SPREADSHEET_KEY']
Feedback.assisted_digital_help_with_fees_spreadsheet = GoogleSpreadsheetStore.new(key)

