module EmailSurveyHelpers
  def create_education_email_survey
    EmailSurvey.new(
      id: 'education_email_survey',
      url: 'http://survey.example.com/1',
      start_time: 1.day.ago,
      end_time: 2.days.from_now,
      name: 'My name is: Education survey'
    )
  end

  def stub_surveys_data(*surveys)
    surveys_data = surveys.each.with_object({}) { |s, data| data[s.id] = s }
    stub_const('EmailSurvey::SURVEYS', surveys_data)
  end
end
