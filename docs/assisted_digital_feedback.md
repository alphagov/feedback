# Assisted Digital Feedback

Assisted Digital feedback is stored twice.  The standard service feedback
component is sent to support-api like other tickets, but the rest of the
feedback specifically about assisted digital support is stored in a google
spreadsheet.  The ID of the spreadsheet to store the data in is set via the
following environment variable:

    ASSISTED_DIGITAL_GOOGLE_SPREADSHEET_KEY

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
