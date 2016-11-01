class ContactLinks
  def initialize(table)
    @table = table
  end

  def popular
    @table.select { |link| link["Type"] == "popular" }
  end

  def long_tail
    @table.select { |link| link["Type"] == "long-tail" }
  end
end
