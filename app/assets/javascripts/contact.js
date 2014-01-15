//= require jquery
//= require jquery-ui
//= require jquery.select-to-autocomplete
//= require govuk/multivariate-test
//= require select

var sections_variant = '<nav class="section"> <div class="section-title"> <h2>Popular Topics</h2> </div> <div class="section-details"> <p>Try one of the popular topics below to get a faster answer.</p> <ul class="categories group"> <li> <h2><a href="/contact-the-dvla">Driving licences and car tax</a></h2> <p>Contact DVLA for questions about driving and your vehicle.</p> </li> <li> <h2><a href="/contact/look-for-jobs">Help with Universal Jobmatch</a></h2> <p>Ask a question about the service or retrieve your lost login details.</p> </li> <li> <h2><a href="/passport-advice-line">Passport Advice Line</a></h2> <p>Get help with your passport application and renewals if you\'re a British Citizen.</p> </li> <li> <h2><a href="/contact-student-finance-england">Student Finance England</a></h2> <p>Get help with student loan applications and grants.</p> </li> <li> <h2><a href="/contact-jobcentre-plus">Jobcentre Plus</a></h2> <p>Get advice on benefits such as Jobseeker\'s Allowance (JSA).</p> </li> </ul> </div> </nav> <nav class="section other"> <div class="section-title"> <h2>Other popular topics</h2> <form id="contact-form"> <label>Find contact details for </label> <br> <select class="contact-search" name="Contacts" id="contact-selector" autocorrect="on" autocomplete="on"> <option value="" selected="selected"></option> </select> </form> </div> <div class="section-details"> <div id="contact-info" style="display:none;"> <ul> <li> <h2><a href="" id="contact-title"></a></h2> <p id="contact-description"></p> </li> </ul> </div> </div> <div style="clear:both;"></div> </nav> <nav class="section"> <div class="section-title"> <h2>Questions &amp; comments</h2> </div> <div class="section-details"> <p>Use the <a href="/contact/govuk">GOV.UK form</a> to send your questions or comments about the website.</p> <p>Check the <a href="/help">GOV.UK help pages</a> to find out about the use of cookies, accessibility of the site, the privacy policy and terms and conditions of use.</p> </div> </nav>';

var test = new GOVUK.MultivariateTest({
  name: 'govuk_contact_page',
  customVarIndex: 13,
  cohorts: {
    control: {callback: function() { return false; }},
    sections_variant: {
      callback: function() {
        $('.contact-container').html(sections_variant);
        $('.contact-container').show();
      }
    },
  }
});
