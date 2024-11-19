class AppTicket
  include ActiveModel::Model

  attr_accessor :giraffe

  MAX_FIELD_CHARACTERS = 1250

  def valid_ticket?
    giraffe.blank? && valid?
  end
end
