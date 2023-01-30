describe('Feedback', function () {
  'use strict'

  it('can extract a path from a URL', function () {
    expect(GOVUK.feedback.getPathFor('http://example.com/this/is/the/path')).toBe('/this/is/the/path')
  })

  describe('when on the contact page', function () {
    var locationPathnameSpy

    beforeEach(function () {
      locationPathnameSpy = spyOn(GOVUK.feedback, 'getLocationPathname').and.returnValue('/contact')
      GOVUK.feedback.init()
    })

    afterEach(function () {
      locationPathnameSpy.and.callThrough()
    })

    it('stores the referrer in a cookie', function () {
      expect(GOVUK.getCookie('govuk_contact_referrer')).toBe(document.referrer)
    })
  })

  describe('when there is a feedback form on the page', function () {
    var contactForm, linkInput, specificLocationInput, javascriptEnabledInput, referrerInput

    beforeAll(function () {
      contactForm = document.createElement('form')
      contactForm.setAttribute('class', 'contact-form')
      linkInput = document.createElement('input')
      linkInput.setAttribute('name', 'contact[link]')
      contactForm.appendChild(linkInput)
      specificLocationInput = document.createElement('input')
      specificLocationInput.setAttribute('name', 'contact[location]')
      specificLocationInput.setAttribute('value', 'specific')
      specificLocationInput.setAttribute('type', 'checkbox')
      contactForm.appendChild(specificLocationInput)
      document.body.appendChild(contactForm)
    })

    beforeEach(function () {
      linkInput.value = ''
      specificLocationInput.checked = false
      GOVUK.feedback.init()
      javascriptEnabledInput = contactForm.querySelector('[name="contact[javascript_enabled]"]')
      referrerInput = contactForm.querySelector('[name="contact[referrer]"]')
    })

    afterEach(function () {
      javascriptEnabledInput.remove()
      referrerInput.remove()
    })

    it('appends a hidden field indicating javascript was enabled', function () {
      expect(javascriptEnabledInput.value).toBe('true')
    })

    it('appends a hidden field recording the referrer', function () {
      expect(referrerInput.value).toBe(document.referrer)
    })

    describe('when no link URL is given', function () {
      it('uses the referrer URL', function () {
        expect(linkInput.value).toBe(document.referrer)
      })
    })

    describe('when a link URL is given', function () {
      beforeEach(function () {
        linkInput.value = 'http://example.com'
        GOVUK.feedback.init()
      })

      it('selects the "A specific page" option', function () {
        expect(specificLocationInput.checked).toBe(true)
      })
    })

    describe('when there is an email address in the specific page URL', function () {
      var cookieSpy

      beforeEach(function () {
        linkInput.value = ''
        var referrerWithEmail = document.referrer + '?email=test@example.com'
        cookieSpy = spyOn(GOVUK, 'cookie').and.returnValue(referrerWithEmail)
        GOVUK.feedback.init()
      })

      afterEach(function () {
        cookieSpy.and.callThrough()
      })

      it('masks all email addresses in the URL', function () {
        expect(linkInput.value).toBe(document.referrer + '?email=[email]')
      })
    })
  })

  describe('when there is a service feedback form on the page', function () {
    var serviceFeedbackForm, javascriptEnabledInput, referrerInput

    beforeAll(function () {
      serviceFeedbackForm = document.createElement('form')
      serviceFeedbackForm.setAttribute('class', 'service-feedback')

      document.body.appendChild(serviceFeedbackForm)
    })

    beforeEach(function () {
      GOVUK.feedback.init()
      javascriptEnabledInput = serviceFeedbackForm.querySelector('[name="service_feedback[javascript_enabled]"]')
      referrerInput = serviceFeedbackForm.querySelector('[name="service_feedback[referrer]"]')
    })

    afterEach(function () {
      javascriptEnabledInput.remove()
      referrerInput.remove()
    })

    it('appends a hidden field indicating javascript was enabled', function () {
      expect(javascriptEnabledInput.value).toBe('true')
    })

    it('appends a hidden field recording the referrer', function () {
      expect(referrerInput.value).toBe(document.referrer)
    })
  })
})
