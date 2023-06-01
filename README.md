# Feedback

This app collects feedback from users via contact forms rendered on GOV.UK.
This data is then sent to the [support](https://github.com/alphagov/support) app or [support-api](https://github.com/alphagov/support-api) app to be dealt with.

## Screenshots

### Contact Page on GOV.UK
![Contact Page on GOV.UK](/docs/screenshots/contact_page.png?raw=true "Contact Page on GOV.UK")

### Contact Form on GOV.UK
![Contact Form on GOV.UK](/docs/screenshots/contact_form.png?raw=true "Contact Form on GOV.UK")

## Live examples

- https://www.gov.uk/contact/
- https://www.gov.uk/contact/govuk
- https://www.gov.uk/contact/govuk/thankyou
- https://www.gov.uk/contact/govuk/anonymous-feedback/thankyou

## Nomenclature

- **Feedback**: All the data received from contact forms is considered to be "feedback" of some form
or other and relates to pages published on GOV.UK.
- **Anonymous Contact**: Part of the feedback collected by this app is anonymous, when it's
submitted via an anonymous contact form.
- **Named Contact**: In contrast with the Anonymous Contact feedback, this is submitted
via a form that will require you to identify yourself. This data is sent directly
to the support app.

## Completed Transaction feedback forms

### Service Feedback
Most of the `/done/completed-transaction` pages render a Service Feedback form. An example is: [www.gov.uk/done/vehicle-tax](http://www.gov.uk/done/vehicle-tax). 

### Assisted Digital Feedback
There are also three assisted digital feedback forms:

- https://www.gov.uk/done/register-flood-risk-exemption
- https://www.gov.uk/done/waste-carrier-or-broker-registration
- https://www.gov.uk/done/register-waste-exemption

### Transaction finished

The transaction finished page can be found here: https://www.gov.uk/done/transaction-finished.
This doesn’t display a form, just content to inform the user that the transaction is finished.

### Where is the data sent?

The Service Feedback form fields also exist within the Assisted Digital Feedback form. They are foundationally the same, but Assisted Digital Feedback has some extra fields.

The Service Feedback form data from both types of form is sent to the Support API. It can be viewed using the Support app within the Feedback Explorer.

In addition to sending some data to the Support API, the data from the other fields (from the Assisted Digital Feedback form) plus some data from hidden fields appended using JS (`referrer` and `javascript_enabled`) are written to a Google spreadsheet.

For submitting the Assisted Digital Feedback form, you will need to get the Google API credentials from AWS secrets/integration. To use them locally, create a .dotenv file and write them in:

```
GOOGLE_PRIVATE_KEY=
GOOGLE_CLIENT_EMAIL=
ASSISTED_DIGITAL_GOOGLE_SPREADSHEET_KEY=
``` 

The `.env` file is listed within the `.gitignore` file. Do not push the `.env` file to version control.

Completed transaction feedback forms were previously rendered by the Frontend application. [Rendering was moved into this application](https://github.com/alphagov/feedback/pull/1601) which enabled the implementation of form validation. 


## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

### Running the test suite

```
bundle exec rake
```

## Further documentation

- [Testing with real authorisation](docs/testing_with_real_authorisation.md)
- [Assisted digital feedback workflow](docs/assisted_digital_feedback.md)
- [Email survey signups feedback](docs/email_survey_signups.md)

## Licence

[MIT License](LICENCE)
