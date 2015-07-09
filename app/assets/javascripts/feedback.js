//= require jquery.details.js

(function(){
  "use strict";

  window.GOVUK = GOVUK || {};

  GOVUK.feedback = {};

  GOVUK.feedback.checkEmail = function (input) {
    if (input.setCustomValidity) {
      if (input.value != $('#email').val()) {
        input.setCustomValidity('The two email addresses must match.');
      } else {
        input.setCustomValidity('');
      }
    }
  };

  GOVUK.feedback.checkOnInputEmail = function () {
    this.onkeydown = null;
    GOVUK.feedback.checkEmail(this);
  };

  GOVUK.feedback.checkOnKeyDownEmail = function () {
    GOVUK.feedback.checkEmail(this);
  };

  GOVUK.feedback.initUserDetails = function () {
    $('#verifyemail').on('input', GOVUK.feedback.checkOnInputEmail);
    $('#verifyemail').on('keydown', GOVUK.feedback.checkOnKeyDownEmail);
  }

  GOVUK.feedback.handleCounter = function (counted) {
    var counterId = '#' + counted.id + 'counter';
    $(counterId).html((1200 - counted.value.length) +  " characters remaining (limit is 1200 characters)");
  }

  GOVUK.feedback.initCounters = function () {
    $('.counted').each(function (index) {
      this.oninput = function () {
        this.onkeydown = null;
        GOVUK.feedback.handleCounter(this);
      };

      this.onkeydown = function () {
        GOVUK.feedback.handleCounter(this);
      };
    });
  }

  GOVUK.feedback.checkRadio = function () {
    if ($('#location-specific').is(':checked')) {
      $('#link').removeAttr('disabled');
    } else {
      $('#link').attr('disabled', 'disabled')
    }
  }

  GOVUK.feedback.saveReferrerToCookie = function () {
    GOVUK.cookie('govuk_contact_referrer', document.referrer, { days: 1 });
  }

  GOVUK.feedback.prepopulateFormBasedOnReferrer = function () {
    var specificPage = GOVUK.cookie('govuk_contact_referrer') || document.referrer;

    // Preopulate specific page field
    $('#link').val(specificPage);

    // Choose "A specific page" option if the form was linked to directly
    if (specificPage && !(GOVUK.feedback.getPathFor(specificPage) == "/contact")) {
      $('#location-specific').click();
    }
  }

  GOVUK.feedback.getPathFor = function (url) {
    var link = document.createElement("a");
    link.href = url;
    return link.pathname;
  }

  GOVUK.feedback.init = function () {
    GOVUK.feedback.initCounters();
    GOVUK.feedback.initUserDetails();
    GOVUK.feedback.checkRadio();

    $('button.button').click(function() {
      $(this).attr('disabled', 'disabled');
      $(this).parents('form').submit();
    });

    $('fieldset#location').change(function () {
      GOVUK.feedback.checkRadio();
    });

    if (window.location.pathname == "/contact") {
      GOVUK.feedback.saveReferrerToCookie();
    }

    GOVUK.feedback.prepopulateFormBasedOnReferrer();
    $('form.contact-form').append('<input type="hidden" name="contact[javascript_enabled]" value="true"/>');
    $('form.contact-form').append('<input type="hidden" name="contact[referrer]" value="' + document.referrer + '"/>');

    $('details').details();
    $('html').addClass($.fn.details.support ? 'details' : 'no-details');
  }

  $(GOVUK.feedback.init);

}());
