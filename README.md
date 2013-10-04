feedback
========

This app handles user feedback related things.

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
