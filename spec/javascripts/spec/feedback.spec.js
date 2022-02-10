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
    var contactForm

    beforeAll(function () {
      contactForm = document.createElement('form')
      contactForm.setAttribute('class', 'contact-form')
      var link = document.createElement('input')
      link.setAttribute('name', 'contact[link]')
      contactForm.appendChild(link)
      contactForm.link = link
      var sloc = document.createElement('input')
      sloc.setAttribute('name', 'contact[location]')
      sloc.setAttribute('value', 'specific')
      sloc.setAttribute('type', 'checkbox')
      contactForm.appendChild(sloc)
      contactForm.specificLocation = sloc
      document.body.appendChild(contactForm)
    })

    beforeEach(function () {
      contactForm.link.value = ''
      contactForm.specificLocation.checked = false
      GOVUK.feedback.init()
      contactForm.javascriptEnabled = contactForm.querySelector('[name="contact[javascript_enabled]"]')
      contactForm.referrer = contactForm.querySelector('[name="contact[referrer]"]')
    })

    afterEach(function () {
      contactForm.javascriptEnabled.remove()
      contactForm.referrer.remove()
    })

    it('appends a hidden field indicating javascript was enabled', function () {
      expect(contactForm.javascriptEnabled.value).toBe('true')
    })

    it('appends a hidden field recording the referrer', function () {
      expect(contactForm.referrer.value).toBe(document.referrer)
    })

    describe('when no link URL is given', function () {
      it('uses the referrer URL', function () {
        expect(contactForm.link.value).toBe(document.referrer)
      })
    })

    describe('when a link URL is given', function () {
      beforeEach(function () {
        contactForm.link.value = 'http://example.com'
        GOVUK.feedback.init()
      })

      it('selects the "A specific page" option', function () {
        expect(contactForm.specificLocation.checked).toBe(true)
      })
    })

    describe('when there is an email address in the specific page URL', function () {
      var cookieSpy

      beforeEach(function () {
        contactForm.link.value = ''
        var referrerWithEmail = document.referrer + '?email=test@example.com'
        cookieSpy = spyOn(GOVUK, 'cookie').and.returnValue(referrerWithEmail)
        GOVUK.feedback.init()
      })

      afterEach(function () {
        cookieSpy.and.callThrough()
      })

      it('masks all email addresses in the URL', function () {
        expect(contactForm.link.value).toBe(document.referrer + '?email=[email]')
      })
    })
  })
})
