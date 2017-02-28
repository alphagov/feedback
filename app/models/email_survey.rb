class EmailSurvey
  attr_accessor :id, :url, :start_time, :end_time, :name
  def initialize(id:, url:, start_time:, end_time:, name:nil)
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
    SURVEYS.fetch(id)
  end

  SURVEYS = Hash[
    [
      new(
        id: 'education_email_survey',
        url: 'https://smartsurvey.co.uk.example.com/survey/1234',
        start_time: Time.zone.parse("2017-02-23").beginning_of_day,
        end_time: Time.zone.parse("2017-03-05").end_of_day,
        name: 'education user research'
      ).freeze,
    ].map { |s| [s.id, s] }
  ].freeze
end
