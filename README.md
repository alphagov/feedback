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

Authorisation for writing to the spreadsheet must be granted to the app.

1.  Generate a service account (see [Google's documentation](https://developers.google.com/identity/protocols/OAuth2ServiceAccount))
    and store the JSON key somewhere safe.
2.  Extract the `client_email` value from the JSON key and make it available to
    the app in the `GOOGLE_CLIENT_EMAIL` environment variable.
3.  Extract the `private_key` value from the JSON key and make it avaiable to
    the app via the `GOOGLE_PRIVATE_KEY` environment variable.
4.  Share the spreadsheet that you want to write data to with the email address
    stored in the `GOOGLE_CLIENT_EMAIL`.  It should have at least "can edit"
    permissions so the application can write data to the sheet.

### Email Survey Signups

This type of feedback is not actually feedback, it's a response from a banner
displayed by static asking users to provide an email address where we can send
them a link to a survey.  You can find out more about surveys in static [by
reading the documentation](https://github.com/alphagov/static/blob/master/doc/surveys.md).

The request will contain an `email_address` (the users email address), a
`survey_source` (the path on GOV.UK where the sign up form was displayed), and
`survey_id` (the survey they were invited to take part in).  The `survey_id`
should match with an instance of `EmailSurvey` defined in [`app/models/email_survey.rb`.](app/models/email_survey.rb)
These instances, like their counterparts in static, have start and endtimes so
that we don't send emails when the survey has closed.  Unlike their counterparts
in static they do not have match rules on the path - response that gets past an
`survey_id` check and is in the `active?` time period will be sent an email.

The email is sent using GOV.UK Notify using the "GOV.UK Surveys" service and a
hardcoded email template (name: `email_survey_signup`, id: `8fe8ab4f-a6ac-44a1-9d8b-f611a493231b`)
that belongs to that service.  This means that all running instances must use
API keys for the same service or the template won't exist.  The API key is
provided with the env var:

    SURVEY_NOTIFY_SERVICE_API_KEY

Deployed environments have this filled in via puppet and our standard mechanism
for handling keys.  On the GOV.UK dev vm you'll want to join the service on
GOV.UK Notify and create your own  API key.  When creating a key for yourself
choosese either:

* "test" - which won't send any emails at all, but will give you valid
           responses from the API
* "team" - which will only send emails to people on the team or the whitelisted
           email addresses.

Note that future versions may allow for different surveys to use different
templates, but they'll still all have to belong to the same Notify service.

#### A note on Notify template parameters

Notify templates can be parameterised, and when we talk to the notify API we
send a `personalisation` key that contains values for all the parameters in the
template.  Notify will error if there are missing keys, but it will also error
if there are extra keys.  This means we have to take care when editing the
template in the Notify UI and take care not to introduce, nor remove parameters
without updating the code.

Currently the template takes a single parameter:

* `survey_url` - the url that the survey lives at and will be sent in the email
                 to invite the user to take part in that survey - this is
                 constructed by taking the `url` of the `EmailSurvey` instance
                 and adding the `survey_source` as a `c` param to the query
                 string.

Adding new parameters will require a deploy, so it might be best to add a new
template with new parameters and have the deploy change the template id *and*
the parameters.
