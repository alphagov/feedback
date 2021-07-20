class MultiTicket
  attr_reader :ticket_types

  def initialize(*ticket_types)
    @ticket_types = ticket_types
  end

  def new(data)
    Instance.new(@ticket_types.map { |ticket_type| ticket_type.new(data) })
  end

  class Instance
    attr_reader :tickets

    def initialize(tickets)
      @tickets = tickets
    end

    def valid?
      @tickets.all?(&:valid?)
    end

    def save
      @tickets.each(&:save)
    end

    def spam?
      @tickets.any?(&:spam?)
    end

    def errors
      errors = ActiveModel::Errors.new(self)
      @tickets.map(&:errors).each do |ticket_errors|
        ticket_errors.each do |attribute, error|
          errors.add(attribute, error)
        end
      end
      errors
    end
  end
end
