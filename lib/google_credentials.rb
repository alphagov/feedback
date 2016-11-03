require 'googleauth'

class GoogleCredentials
  def self.authorization(scopes)
    raise ArgumentError, "Must define GOOGLE_PRIVATE_KEY and GOOGLE_CLIENT_EMAIL in order to authenticate." unless all_configuration_in_env?
    # NOTE: we should be able to use:
    #     ENV['GOOGLE_ACCOUNT_TYPE'] = 'service_account'
    #     Google::Auth.get_default_credentials(scopes)
    # here instead of reaching further into the API, but there is a bug in
    # the version of the gem we use (0.5.1) that means it doesn work.  It's been
    # fixed in master (see: https://github.com/google/google-auth-library-ruby/commit/62a8d41bc4e3274f9f3b7ceab63a040912ee2bdc)
    # but not released.  When a version is released we can change this to use
    # the above code.  We might want to add a guard if GOOGLE_ACCOUNT_TYPE is
    # already set, but not set to 'service_account'.
    Google::Auth::ServiceAccountCredentials.make_creds(scope: scopes)
  end

  def self.all_configuration_in_env?
    %w(GOOGLE_PRIVATE_KEY GOOGLE_CLIENT_EMAIL).all? { |env_var| ENV[env_var].present? }
  end
  private_class_method :all_configuration_in_env?
end
