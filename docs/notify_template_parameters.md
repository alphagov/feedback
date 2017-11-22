# Notify template parameters

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
                 string. At the end of the url we will also add the `ga_client_id`
                 (e.g. if we have ga_client_id = '12345.67899' then the resulting 
                 `survey_url` will be appended with `&gcl=12345.67890`)

Adding new parameters will require a deploy, so it might be best to add a new
template with new parameters and have the deploy change the template id *and*
the parameters.
