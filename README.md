feedback
========

This app handles user feedback related things.

Zendesk config
--------------

This is read from config/zendesk.yml. By default this sets development_mode to true.

In development mode ticket details will simply be echoed to the Rails log, and not actually submitted to zendesk.  Additionally, if the ticket description contains the string 'break_zendesk', it will simulate a failure creating a ticket.

To test actually submitting tickets to zendesk in development, copy `zendesk_example.yml` over the top of `zendesk.yml`, and add your own Zendesk credentials to the file.   **DO NOT COMMIT THIS FILE**

### Testing

To run unit tests, execute the following:

    bundle exec rake

### Testing with a mock `signon` strategy

Launch using `bowl` from the `development` directory:

    development> bowl feedback

### Testing with a instance of `signon`

In order to raise tickets in Zendesk, the `feedback` app submits data to the `support` app. As the relevant `support` app endpoints are behind `signon`, `feedback` needs a bearer token for authorisation. To get this set up:

1. Create an API user within `signon`:

        signonotron2> bundle exec rake "api_clients:create[Feedback app,feedback@alphagov.co.uk,support,api_users]"

2. Copy the resulting bearer token into `config/initializers/support_app.rb`.

To start with a "real" `signon`:

    development> GDS_SSO_STRATEGY=real bowl signon feedback