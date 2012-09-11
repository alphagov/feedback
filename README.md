feedback
========

This app handles user feedback related things.

Zendesk config
--------------

This is read from config/zendesk.yml. By default this sets development_mode to true.

In development mode ticket details will simply be echoed to the Rails log, and not actually submitted to zendesk.  Additionally, if the ticket description contains the string 'break_zendesk', it will simulate a failure creating a ticket.

To test actually submitting tickets to zendesk in development, copy `zendesk_example.yml` over the top of `zendesk.yml`, and add your own Zendesk credentials to the file.   **DO NOT COMMIT THIS FILE**
