//= require govuk/multivariate-test

var test = new GOVUK.MultivariateTest({
  name: 'govuk_contact_page',
  customVarIndex: 13,
  cohorts: {
    control: {callback: function() { return false; }},
    boop: {callback: function() { alert("boop"); } },
  }
});
