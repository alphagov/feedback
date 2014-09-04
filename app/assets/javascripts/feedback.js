//= require jquery.details.js
//= require vendor/polyfills/bind
//= require govuk/selection-buttons

var GOVUK = GOVUK || {};

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

GOVUK.feedback.prepopulateFormBasedOnReferrer = function () {
    $('#link').val(document.referrer);
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

    GOVUK.feedback.prepopulateFormBasedOnReferrer();
    $('form.contact-form').append('<input type="hidden" name="contact[javascript_enabled]" value="true"/>');
    $('form.contact-form').append('<input type="hidden" name="contact[referrer]" value="' + document.referrer + '"/>');

    $('details').details();
    $('html').addClass($.fn.details.support ? 'details' : 'no-details');
}

$(GOVUK.feedback.init);

$(document).ready(function() {
  var $buttons = $("label input[type='radio'], label input[type='checkbox']");
  GOVUK.selectionButtons($buttons);
});
