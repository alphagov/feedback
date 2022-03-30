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

## License

[MIT License](LICENSE)
