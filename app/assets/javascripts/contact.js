//= require jquery
//= require jquery-ui
//= require jquery.select-to-autocomplete
//= require govuk/multivariate-test
//= require select
//= require jquery.details

GOVUK.showPage = function() {
  $('.contact-contents').show();
};

var test = new GOVUK.MultivariateTest({
  name: 'govuk_contact_page',
  customVarIndex: 13,
  cohorts: {
    control: {
      callback: function() {
        GOVUK.showPage();
      }
    },
    sections_variant: {
      callback: function() {
        $('.contact-container').html($('#sections-variant').html());
        GOVUK.showPage();
      }
    },
    searchbox_variant: {
      callback: function() {
        $('.contact-container').html($('#searchbox-variant').html());
        GOVUK.showPage();
      }
    },
    lists_variant: {
      callback: function() {
        $('.contact-container').html($('#lists-variant').html());
        $('details').details();
        $('html').addClass($.fn.details.support ? 'details' : 'no-details');
        GOVUK.showPage();
      }
    },
  }
});
