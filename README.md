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

### Testing with real authorisation

In order to raise tickets in Zendesk, the `feedback` app submits data to the `support` app. As the relevant `support` app endpoints are behind `signon`, `feedback` needs a bearer token for authorisation. To get this working after an import of signon data from preview:

1. Copy the token from the [support app initializer](config/initializers/support_app.rb).

2. Start a rails console session within `signon`:

        signonotron2> bundle exec rails c

3. Execute the following (to update the token):

    u = User.find_by_email('feedback@alphagov.co.uk')
    a = u.authorisations.first
    a.token = "<PLACE TOKEN HERE>"
    a.save

4. To start with real authentication using `signon` and `support`:

    development> GDS_SSO_STRATEGY=real bowl signon support feedback
