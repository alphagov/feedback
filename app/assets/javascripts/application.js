//= require vendor/jquery.inputevent
//= require govuk_publishing_components/lib
//= require govuk_publishing_components/components/button
//= require govuk_publishing_components/components/character-count
//= require govuk_publishing_components/components/details
//= require govuk_publishing_components/components/error-summary
//= require govuk_publishing_components/components/feedback
//= require govuk_publishing_components/components/radio

(function () {
  'use strict'

  window.GOVUK = GOVUK || {}

  GOVUK.feedback = {}

  GOVUK.feedback.checkEmail = function (input) {
    if (input.setCustomValidity) {
      if (input.value !== $('#email').val()) {
        input.setCustomValidity('The two email addresses must match.')
      } else {
        input.setCustomValidity('')
      }
    }
  }

  GOVUK.feedback.checkOnInputEmail = function () {
    this.onkeydown = null
    GOVUK.feedback.checkEmail(this)
  }

  GOVUK.feedback.checkOnKeyDownEmail = function () {
    GOVUK.feedback.checkEmail(this)
  }

  GOVUK.feedback.initUserDetails = function () {
    $('#verifyemail').on('input', GOVUK.feedback.checkOnInputEmail)
    $('#verifyemail').on('keydown', GOVUK.feedback.checkOnKeyDownEmail)
  }

  GOVUK.feedback.handleCounter = function (counted) {
    var counterId = '#' + counted.id + 'counter'
    var maxLength = 1200
    var currentLength = counted.value.length
    var remainingNumber = maxLength - currentLength
    var thresholdValue = maxLength * 90 / 100 // 90% of the total maximum length
    var charVerb = (remainingNumber < 0) ? 'too many' : 'remaining'
    var charNoun = 'character' + ((remainingNumber === -1 || remainingNumber === 1) ? '' : 's')
    var displayNumber = Math.abs(remainingNumber)
    $(counterId).html((displayNumber) + ' ' + charNoun + ' ' + charVerb + ' (limit is ' + maxLength + ' characters)')

    // remove aria attributes when users start typing
    $(counterId).removeAttr('aria-live aria-atomic')

    // only add the screenreader anouncements when threshold is reached
    if (currentLength > thresholdValue) {
      $(counterId).attr({
        'aria-live': 'polite',
        'aria-atomic': 'false'
      })
    }
  }

  GOVUK.feedback.initCounters = function () {
    $('.counted').each(function (index) {
      $(this).on('txtinput', function () {
        GOVUK.feedback.handleCounter(this)
      })
    })
  }

  GOVUK.feedback.saveReferrerToCookie = function () {
    GOVUK.cookie('govuk_contact_referrer', document.referrer, { days: 1 })
  }

  GOVUK.feedback.prepopulateFormBasedOnReferrer = function () {
    var specificPage = GOVUK.cookie('govuk_contact_referrer') || document.referrer

    // Mask email addresses
    var emailPattern = /[^\s=/?&]+(?:@|%40)[^\s=/?&]+/g
    specificPage = specificPage.replace(emailPattern, '[email]')

    // Preopulate specific page field
    if (specificPage && !(GOVUK.feedback.getPathFor(specificPage).startsWith('/contact'))) {
      $('#link').val(specificPage)
    }

    // Choose "A specific page" option if the form was linked to directly
    if (specificPage && !(GOVUK.feedback.getPathFor(specificPage) === '/contact')) {
      $('#location-specific').click()
    }
  }

  GOVUK.feedback.getPathFor = function (url) {
    var link = document.createElement('a')
    link.href = url
    return link.pathname
  }

  GOVUK.feedback.init = function () {
    GOVUK.feedback.initCounters()
    GOVUK.feedback.initUserDetails()

    if (window.location.pathname === '/contact') {
      GOVUK.feedback.saveReferrerToCookie()
    }

    GOVUK.feedback.prepopulateFormBasedOnReferrer()
    $('form.contact-form').append('<input type="hidden" name="contact[javascript_enabled]" value="true"/>')
    $('form.contact-form').append('<input type="hidden" name="contact[referrer]" value="' + document.referrer + '"/>')
  }

  $(GOVUK.feedback.init)
}())
