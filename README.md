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

### Assisted Digital Help With Fees Feedback

This feedback is not stored in the support-api like the other tickets.  This data
is stored in a google spreadsheet.  The ID of the spreadsheet to store the data
in is set via the following environment:

    ASSISTED_DIGITAL_HELP_WITH_FEES_GOOGLE_SPREADSHEET_KEY

To find the ID of a spreadsheet you wish to use, the [following documentation
from google is useful](https://developers.google.com/sheets/guides/concepts#spreadsheet_id).

Authorisation for writing to the spreadsheet must be granted to the app.  We use
a service account JSON key (see [Google's documentation](https://developers.google.com/identity/protocols/OAuth2ServiceAccount)).
Once you have generated your service account key, place a copy of the JSON key
in:

    config/google-credentials.json

You must also take the `client_email` value from that file and share the
spreadsheet with that email address, giving it at least "can edit" permissions
so the application can write data back.
