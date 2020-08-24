# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += %i[
  password
  name
  email
  email_confirmation
  textdetails
  what_doing
  what_wrong
]
