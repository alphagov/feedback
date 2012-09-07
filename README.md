feedback
========

This app handles user feedback related things.

Zendesk config
--------------

This is read from config/zendesk.yml. By default this sets development_mode to true.  In this case ticket details will simply be echoed to the Rails log.  

To test actually submitting tickets to zendesk in development, copy `zendesk_example.yml` over the top of `zendesk.yml`, and add your own Zendesk credentials to the file.   **DO NOT COMMIT THIS FILE**
