require 'googleauth'

class GoogleCredentials
  def self.authorization(scopes)
    ENV['GOOGLE_APPLICATION_CREDENTIALS'] ||= Rails.root.join('config', 'google-credentials.json').to_s
    Google::Auth.get_application_default(scopes)
  end
end
