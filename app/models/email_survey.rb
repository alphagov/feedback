class EmailSurvey
  class NotFoundError < StandardError; end
  attr_accessor :id, :url, :start_time, :end_time, :name
  def initialize(id:, url:, start_time:, end_time:, name: nil)
    self.id = id
    self.url = url
    self.start_time = start_time
    self.end_time = end_time
    self.name = name.present? ? name : id.humanize
  end

  def active?(at: Time.zone.now)
    at.between? start_time, end_time
  end

  def self.all
    SURVEYS.values
  end

  def self.find(id)
    SURVEYS.fetch(id) { |not_found_id| raise NotFoundError.new(not_found_id) }
  end

  # TODO: allow for surveys with no start/end time?
  SURVEYS = Hash[
    [
      # This is the default survey that runs across the whole site
      # hence the long lived start/end times
      new(
        id: 'user_satisfaction_survey',
        url: 'https://www.smartsurvey.co.uk/s/gov-uk',
        start_time: Time.zone.parse("2017-01-01").beginning_of_day,
        end_time: Time.zone.parse("2116-12-31").end_of_day,
        name: 'GOV.UK user research'
      ).freeze,
      # This is the default survey that runs on the footer
      # hence the long lived start/end times
      new(
        id: 'footer_satisfaction_survey',
        url: 'https://www.smartsurvey.co.uk/s/0087N',
        start_time: Time.zone.parse("2017-01-01").beginning_of_day,
        end_time: Time.zone.parse("2116-12-31").end_of_day,
        name: 'GOV.UK user research'
      ).freeze,
      new(
        id: 'treetest_pre_test_signup',
        url: 'https://signup.take-part-in-research.service.gov.uk/contact?utm_campaign=crowd-banner&utm_source=Other&utm_medium=gov.uk&t=GDS&id=119',
        start_time: Time.zone.parse('2018-01-22').beginning_of_day,
        end_time: Time.zone.parse('2018-01-23').end_of_day,
        name: 'GOV.UK user research'
      ).freeze,
    ].map { |s| [s.id, s] }
  ].freeze
end
