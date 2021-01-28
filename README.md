# Feedback

This app collects feedback from users via contact forms rendered on GOV.UK.
This data is then sent to the `support` app or `support-api` app to be dealt with.

## Contact Page on GOV.UK
![Contact Page on GOV.UK](/docs/screenshots/contact_page.png?raw=true "Contact Page on GOV.UK")

## Contact Form on GOV.UK
![Contact Form on GOV.UK](/docs/screenshots/contact_form.png?raw=true "Contact Form on GOV.UK")

## Nomenclature

- **Feedback**: All the data received from contact forms is considered to be "feedback" of some form
or other and relates to pages published on GOV.UK.
- **Anonymous Contact**: Part of the feedback collected by this app is anonymous, when it's
submitted via an anonymous contact form in the [feedback app][feedback].
- **Named Contact**: In contrast with the `Anonymous Contact` feedback, this is submitted
via a form that will require you to identify yourself. This data is sent directly
to the `support` app.

## Pages rendered by the application

Note that this list may not be complete.

- https://www.gov.uk/contact/
- https://www.gov.uk/contact/govuk
- https://www.gov.uk/contact/govuk/thankyou
- https://www.gov.uk/contact/govuk/anonymous-feedback/thankyou

## Technical documentation

This is a public facing Ruby on Rails application that collects feedback from users in multiple ways:

1. Renders a contact page on GOV.UK: `https://www.gov.uk/contact/govuk`
2. Collects feedback from other contact forms. Pages using the `static` app
will have a link at the bottom of the page asking: `Is there anything wrong with this page?`.
Clicking this link will show you
a form. The data from the form will be submitted to the `feedback` app.
3. Sends feedback either to the `support` app or the `support-api` app. If the
feedback is sent to the `support` app, it will in turn create a ticket in Zendesk.
If it's sent to the `support-api` app then it will either be stored in a database
or a Zendesk ticket will be created.
4. A certain subset of tickets ('assisted digital') have a special workflow: they're
sent once to a Google spreadsheet via the Google API, and then a subset of the data
is sent to `support-api` which will save them in its database. More documentation about
that here: [docs/assisted_digital_feedback.md](docs/assisted_digital_feedback.md).
5. Handles email survey signups. A banner that shows up on `gov.uk` will ask you to
provide an email to signup to a survey. `feedback` will then email you a link to the
survey. However, it does not collect the answers. More documentation about that here:
[docs/email_survey_signups.md](docs/email_survey_signups.md)

### Dependencies

- [support-api](https://github.com/alphagov/support-api) - provides an API for storing and fetching anonymous feedback about pages on GOV.UK. Data comes in from the [feedback app][feedback] on the public-facing frontend and is read by [the support app][support] on the admin-facing backend.
- [support](https://github.com/alphagov/support) - receives feedback from the `feedback` app and creates Zendesk tickets from it.
- [static](https://github.com/alphagov/static) - renders contact forms that will collect information that will be sent to the `feedback` app.

### Running the application

To start the app using [govuk-docker](https://github.com/alphagov/govuk-docker), after making the app via the instructions in the govuk-docker repo, navigate to your local repo directory and run:

    govuk-docker-up

You can also run the following from outside the repo:

    govuk-docker up feedback-app

The app will then be available locally via http://feedback.dev.gov.uk/contact

To start the app using `bowler`:

    bowl feedback

To start the app directly:

    ./startup.sh

This will start the app on port `3028`.

### Running the test suite

To run unit tests, execute the following:

    bundle exec rake

You can also run these via govuk-docker (if using):

    govuk-docker-run bundle exec rake

#### Manual testing with a mock signon strategy

Launch using `bowl` from the `development` directory:

    development> bowl feedback

#### Manual testing with real authorisation

For the feedback that is sent to the `support` app the `feedback` app needs a
bearer token for authorization because `support` is a backend app protected by
`signon`.  The same is not true for the feedback that is sent to `support-api`
because it's not protected by `signon`.

You can read more about how to obtain authorization in the docs:
[docs/testing_with_real_authorization](docs/testing_with_real_authorization.md).

### Assisted Digital Feedback

Assisted Digital feedback is stored twice.  The standard service feedback
component is sent to support-api like other tickets, but the rest of the
feedback specifically about assisted digital support is stored in a google
spreadsheet.

A more thorough explanation about how assisted digital feedback works can
be found in the docs: [docs/assisted_digital_feedback.md](docs/assisted_digital_feedback.md).

### Email Survey Signups

This type of feedback is not actually feedback, it's a response from a banner
displayed by static asking users to provide an email address where we can send
them a link to a survey. The survey will then be emailed to them via the
`feedback` app. Please be aware that the answers we get back on the survey will
NOT be stored in `feedback`.

A more thorough explanation of how email surveys work can be found in the docs:
[docs/email_survey_signup.md](docs/email_survey_signups.md).
