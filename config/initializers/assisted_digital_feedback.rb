require 'google_spreadsheet_store'

key = ENV['ASSISTED_DIGITAL_GOOGLE_SPREADSHEET_KEY']
Feedback.assisted_digital_spreadsheet = GoogleSpreadsheetStore.new(key)

