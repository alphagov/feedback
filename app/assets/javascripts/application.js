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

  GOVUK.feedback.saveReferrerToCookie = function () {
    GOVUK.cookie('govuk_contact_referrer', document.referrer, { days: 1 })
  }

  GOVUK.feedback.prepopulateFormBasedOnReferrer = function (form) {
    var specificPage = GOVUK.cookie('govuk_contact_referrer') || document.referrer

    // Mask email addresses
    var emailPattern = /[^\s=/?&]+(?:@|%40)[^\s=/?&]+/g
    specificPage = specificPage.replace(emailPattern, '[email]')

    var specificPagePath = GOVUK.feedback.getPathFor(specificPage)
    var linkInput = form.querySelector('input[name="contact[link]"]')
    var locationSpecificInput = form.querySelector('input[name="contact[location]"][value="specific"]')

    // Preopulate specific page field
    if (specificPage && linkInput && !(specificPagePath.startsWith('/contact'))) {
      linkInput.value = specificPage
    }

    // Choose "A specific page" option if the form was linked to directly
    if (specificPage && locationSpecificInput && !(specificPagePath === '/contact')) {
      locationSpecificInput.checked = true
    }
  }

  GOVUK.feedback.getPathFor = function (url) {
    var link = document.createElement('a')
    link.href = url
    return link.pathname
  }

  GOVUK.feedback.appendHiddenInputs = function (form) {
    var jsInput = document.createElement('input')
    jsInput.type = 'hidden'
    jsInput.name = 'contact[javascript_enabled]'
    jsInput.value = 'true'
    form.appendChild(jsInput)

    var referrerInput = document.createElement('input')
    referrerInput.type = 'hidden'
    referrerInput.name = 'contact[referrer]'
    referrerInput.value = document.referrer
    form.appendChild(referrerInput)
  }

  GOVUK.feedback.init = function () {
    if (window.location.pathname === '/contact') {
      GOVUK.feedback.saveReferrerToCookie()
    }

    var form = document.querySelector('form.contact-form')
    if (!form) return

    GOVUK.feedback.prepopulateFormBasedOnReferrer(form)
    GOVUK.feedback.appendHiddenInputs(form)
  }

  GOVUK.feedback.init()
}())
