//= require govuk_publishing_components/lib
//= require govuk_publishing_components/components/step-by-step-nav

(function () {
  'use strict'

  window.GOVUK = GOVUK || {}

  GOVUK.feedback = {}

  GOVUK.feedback.saveReferrerToCookie = function () {
    GOVUK.cookie('govuk_contact_referrer', document.referrer, { days: 1 })
  }

  GOVUK.feedback.prepopulateFormBasedOnReferrer = function (form) {
    var specificPage = GOVUK.cookie('govuk_contact_referrer') || document.referrer

    // Mask email addresses
    var emailPattern = /[^\s=/?&]+(?:@|%40)[^\s=/?&]+/g
    specificPage = specificPage.replace(emailPattern, '[email]')

    var specificPagePath = this.getPathFor(specificPage)
    var linkInput = form.querySelector('input[name="contact[link]"]')
    var locationSpecificInput = form.querySelector('input[name="contact[location]"][value="specific"]')

    // Prepopulate specific page if one is not already set
    if (linkInput && !linkInput.value && specificPagePath !== '/contact') {
      linkInput.value = specificPage
    }

    // Choose "A specific page" option if there is a direct link value
    if (locationSpecificInput && linkInput && linkInput.value) {
      locationSpecificInput.checked = true
    }
  }

  GOVUK.feedback.getPathFor = function (url) {
    var link = document.createElement('a')
    link.href = url
    return link.pathname
  }

  GOVUK.feedback.appendHiddenInputs = function (form, formName) {
    var jsInput = document.createElement('input')
    jsInput.type = 'hidden'
    jsInput.name = formName + '[javascript_enabled]'
    jsInput.value = 'true'
    form.appendChild(jsInput)

    var referrerInput = document.createElement('input')
    referrerInput.type = 'hidden'
    referrerInput.name = formName + '[referrer]'
    referrerInput.value = document.referrer
    form.appendChild(referrerInput)
  }

  GOVUK.feedback.getLocationPathname = function () {
    return window.location.pathname
  }

  GOVUK.feedback.init = function () {
    if (this.getLocationPathname() === '/contact') {
      this.saveReferrerToCookie()
    }

    var form = document.querySelector('form.contact-form')
    var serviceFeedbackForm = document.querySelector('form.service-feedback')

    if (form) {
      this.prepopulateFormBasedOnReferrer(form)
      this.appendHiddenInputs(form, 'contact')
    } else if (serviceFeedbackForm) {
      this.appendHiddenInputs(serviceFeedbackForm, 'service_feedback')
    }
  }

  GOVUK.feedback.init()
}())
