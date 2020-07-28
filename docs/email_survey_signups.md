# Email Survey Signups

This type of feedback is not actually feedback, it's a response from a banner
displayed by static asking users to provide an email address where we can send
them a link to a survey.  You can find out more about surveys in static [by
reading the documentation](https://github.com/alphagov/static/blob/master/doc/surveys.md).

The request will contain an `email_address` (the users email address), a
`survey_source` (the path on GOV.UK where the sign up form was displayed), 
`ga_client_id` (the Google Analytics client ID for that user's session), and
`survey_id` (the survey they were invited to take part in).  The `survey_id`
should match with an instance of `EmailSurvey` defined in [`app/models/email_survey.rb`.](app/models/email_survey.rb)
These instances, like their counterparts in static, have start and endtimes so
that we don't send emails when the survey has closed.  Unlike their counterparts
in static they do not have match rules on the path - response that gets past an
`survey_id` check and is in the `active?` time period will be sent an email.

The email is sent using GOV.UK Notify using the "GOV.UK Public" service, with a distinct
service running per environment. The API key is provided with the env var:

    GOVUK_NOTIFY_API_KEY

The email template is provided with the env var:
    GOVUK_NOTIFY_TEMPLATE_ID

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

### Notify template parameters

Please be aware that notify templates can be parameterised. Notify will error if
we don't send the correct params. You can read more about this in the docs:
[docs/notify_template_parameters.md](docs/notify_template_parameters.md).

NB: Adding new parameters will require a deploy.
