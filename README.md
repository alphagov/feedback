# Feedback

This app collects feedback from users via contact forms rendered on GOV.UK.
This data is then sent to [support-api](https://github.com/alphagov/support-api) app to be dealt with.

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
to Support API, which passes it on to Zendesk.

## Completed Transaction feedback forms

### Service Feedback
Most of the `/done/completed-transaction` pages render a Service Feedback form. An example is: [www.gov.uk/done/vehicle-tax](http://www.gov.uk/done/vehicle-tax).

### Transaction finished

The transaction finished page can be found here: https://www.gov.uk/done/transaction-finished.
This doesn’t display a form, just content to inform the user that the transaction is finished.

### How content is loaded

Content for Completed Transaction pages is retrieved via [`govuk_content_item_loader`](https://github.com/alphagov/govuk_content_item_loader) from either Content Store or Publishing API (GraphQL).

The initial request for the content item is made by the FormatRoutingConstraint, which determines the appropriate route and fetches the required data before the request is passed further down the stack.

### Where is the data sent?

The Service Feedback form data is sent to the Support API. It can be viewed using the Support app within the Feedback Explorer.

Completed transaction feedback forms were previously rendered by the Frontend application. [Rendering was moved into this application](https://github.com/alphagov/feedback/pull/1601) which enabled the implementation of form validation.

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

### Running the test suite

```
bundle exec rake
```
### Debugging support

See [Debugging](docs/debugging-in-vs-code.md)

## Further documentation

- [An overview of how the Feedback and Support API applications fit together](https://docs.google.com/presentation/d/1KNJQsH7Stu1hAe8DL-Zs585Q_yXSleGYiH0G6Sw6rOw/edit#slide=id.g59de842929_0_5) (for internal use only)
- [Testing with real authorisation](docs/testing_with_real_authorisation.md)
- [Spam control methods for the Contact form](https://gov-uk.atlassian.net/wiki/spaces/GOVUK/pages/3665821697/Contact+us+form+-+spam+control) (for internal use only)

## Licence

[MIT License](LICENCE)
