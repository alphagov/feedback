var GOVUK = GOVUK || {};

GOVUK.feedback = {};

GOVUK.feedback.checkEmail = function (input) {
  if (input.value != $('email').value) {
    input.setCustomValidity('The two email addresses must match.');
  } else {
    input.setCustomValidity('');
  }
};

GOVUK.feedback.checkOnInputEmail = function () {
  alert('hej');
  this.onkeydown = null;
  GOVUK.feedback.checkEmail(this);
  alert('hej2');
};

GOVUK.feedback.checkOnKeyDownEmail = function () {
  alert('hopp');
  GOVUK.feedback.checkEmail(this);
  alert('hopp2');
};

GOVUK.feedback.initUserDetails = function () {
  $('#verifyemail').on('input', GOVUK.feedback.checkOnInputEmail);
  $('#verifyemail').on('keydown', GOVUK.feedback.checkOnKeyDownEmail);
}

GOVUK.feedback.handleCounter = function(counted) {
  var counterId = '#' + counted.id + 'counter';
  $(counterId).html(1200 - counted.value.length);
}


GOVUK.feedback.initCounters = function () {

  $('.counted').each(function(index) {
    this.oninput = function () {
      this.onkeydown = null;
      GOVUK.feedback.handleCounter(this);
    };
    this.onkeydown = function () {
      GOVUK.feedback.handleCounter(this);
    };
  });
}

GOVUK.feedback.init = function () {
  GOVUK.feedback.initCounters();
  GOVUK.feedback.initUserDetails();
}

$(GOVUK.feedback.init);
